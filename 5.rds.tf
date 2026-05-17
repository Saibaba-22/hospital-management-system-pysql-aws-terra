# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id]
}

# RDS (FIXED CONFIG)
resource "aws_db_instance" "db" {
identifier        = "myappdb"
engine            = "mysql"
engine_version    = "8.0"
instance_class    = "db.t3.micro"
allocated_storage = 20

  db_name  = var.db_name
  username = var.db_user
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name

  publicly_accessible = false
  skip_final_snapshot = true

    tags = {
    Name = "MySQL-RDS-Instance"
  }
}
