# EC2 PUBLIC IP
output "ec2_public_ip" {
  value = aws_instance.app.public_ip
}

# RDS ENDPOINT
output "db_endpoint" {
  value = aws_db_instance.db.endpoint
}

# DATABASE NAME
output "db_name" {
  value = aws_db_instance.db.db_name
}

# DATABASE USERNAME
output "db_username" {
  value = aws_db_instance.db.username
}

# DATABASE PASSWORD (sensitive)
output "db_password" {
  value     = aws_db_instance.db.password
  sensitive = true
}

# Kubernetes Cluster
output "cluster_id" {
  value = aws_eks_cluster.sai01.id
}

output "node_group_id" {
  value = aws_eks_node_group.sai01
}

output "vpc_id" {
  value = aws_vpc.sai01_vpc.id
}

output "subnet_ids" {
  value = ( aws_subnet.sai01_public_subnet[*].id)
}
