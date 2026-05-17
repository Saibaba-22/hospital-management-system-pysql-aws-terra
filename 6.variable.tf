variable "db_name" {
  default = "employeedb"
}

variable "db_user" {
  default = "ordinary"
}

variable "db_password" {
  default = "Database12345"
}

variable "db_port" {
  default = "3306"
}

variable "ec2_name" {
  default = " 3 Tier Hospital "
}

variable "frontend_image" {
  default = "saibaba22/hospital-mgmt:hospital-front"
}

variable "backend_image" {
  default = "saibaba22/hospital-mgmt:hospital-back"
}

variable "ec2_key" {
  description = "The name of the SSH key pair to use for instances"
  type        = string
  default     = "ec2-key"
}
