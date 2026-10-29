
import json
import logging
import os
from decimal import Decimal
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit

import psycopg
from azure.identity import ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ha-retail-api")

HOST = "0.0.0.0"
PORT = int(os.getenv("PORT", "8080"))

KEY_VAULT_URL = os.environ["KEY_VAULT_URL"]
DB_HOST = os.environ["DB_HOST"]
DB_NAME = os.getenv("DB_NAME", "retaildb")
DB_USER = os.getenv("DB_USER", "retailapp")
DB_PASSWORD_SECRET_NAME = os.getenv(
    "DB_PASSWORD_SECRET_NAME", "retailapp-db-password"
)

credential = ManagedIdentityCredential()
secret_client = SecretClient(
    vault_url=KEY_VAULT_URL,
    credential=credential,
)

# Retrieve the password through the VM's managed identity.
DB_PASSWORD = secret_client.get_secret(
    DB_PASSWORD_SECRET_NAME
).value

DB_CONFIG = {
    "host": DB_HOST,
    "port": 5432,
    "dbname": DB_NAME,
    "user": DB_USER,
    "password": DB_PASSWORD,
    "sslmode": "require",
    "connect_timeout": 5,
}


def initialize_database():
    """Create the application table and insert initial sample products."""
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS app.products (
                    id INTEGER PRIMARY KEY,
                    name TEXT NOT NULL,
                    price NUMERIC(10, 2) NOT NULL
                        CHECK (price >= 0)
                )
            """)
            cur.execute("""
                INSERT INTO app.products (id, name, price)
                VALUES
                    (1, 'Everyday Backpack', 29.99),
                    (2, 'Wireless Headphones', 49.99),
                    (3, 'Insulated Water Bottle', 14.99)
                ON CONFLICT (id) DO NOTHING
            """)
        conn.commit()


class Handler(BaseHTTPRequestHandler):
    def send_json(self, status, data):
        body = json.dumps(data).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urlsplit(self.path).path

        if path == "/health":
            try:
                with psycopg.connect(**DB_CONFIG) as conn:
                    with conn.cursor() as cur:
                        cur.execute("SELECT 1")
                self.send_json(200, {
                    "status": "healthy",
                    "service": "ha-retail-demo-api",
                    "database": "connected",
                })
            except Exception:
                logger.exception("Health check failed")
                self.send_json(503, {
                    "status": "unhealthy",
                    "service": "ha-retail-demo-api",
                })
            return

        if path == "/api/products":
            try:
                with psycopg.connect(**DB_CONFIG) as conn:
                    with conn.cursor() as cur:
                        cur.execute("""
                            SELECT id, name, price
                            FROM app.products
                            ORDER BY id
                        """)
                        rows = cur.fetchall()

                products = [
                    {
                        "id": product_id,
                        "name": name,
                        "price": float(price)
                        if isinstance(price, Decimal)
                        else price,
                    }
                    for product_id, name, price in rows
                ]

                self.send_json(200, {
                    "source": "postgresql",
                    "demo_data": True,
                    "products": products,
                })
            except Exception:
                logger.exception("Product query failed")
                self.send_json(503, {
                    "error": "Products are temporarily unavailable"
                })
            return

        self.send_json(404, {
            "error": "Not found",
            "endpoints": ["/health", "/api/products"],
        })

    def log_message(self, format_string, *args):
        logger.info("%s - %s", self.address_string(), format_string % args)


if __name__ == "__main__":
    try:
        initialize_database()
        logger.info("Database initialized; starting API on port %s", PORT)
        server = ThreadingHTTPServer((HOST, PORT), Handler)
        server.serve_forever()
    except Exception:
        logger.exception("API startup failed")
        raise
    finally:
        credential.close()
