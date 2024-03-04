# RDS instance variables (optional, for demonstration)
variable "rds_instance_type" {
  description = "RDS instance type"
  default     = "db.t2.micro"
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  default     = "mydb"
}

variable "db_user" {
  description = "Username for the database"
  default     = "admin"
}

variable "db_password" {
  description = "Password for the database"
  default     = "YourSecurePassword" # Change this to a secure password
}

variable "pem_key" {
  description = "The name of the PEM key to access EC2 instances"
  type = string
  default = "pall"
}