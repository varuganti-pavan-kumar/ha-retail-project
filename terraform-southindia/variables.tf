variable "location" {
  default = "southindia"
}

variable "project_name" {
  default = "ha-retail-southindia"
}

variable "environment" {
  default = "dev"
}

variable "postgresql_admin" {
  description = "Administrator username for PostgreSQL"
  type        = string
  default     = "retailadmin"
}

variable "postgresql_password" {
  description = "Administrator password for PostgreSQL"
  type        = string
  sensitive   = true
}
