resource "aws_db_instance" "temporal_mysql" {
  identifier              = "temporal-mysql"
  allocated_storage       = 20                        # Free Tier storage limit
  max_allocated_storage   = 20
  engine                  = "mysql"
  engine_version          = "8.4.6"                  # pick a supported version
  instance_class          = "db.t3.micro"             # Free Tier eligible
  username                = var.db_username           # e.g. "admin1234"
  password                = var.db_password           # use sensitive variable
  db_name                 = "temporal"
  publicly_accessible     = true                      # or false if only inside VPC
  skip_final_snapshot     = true
  deletion_protection     = false

  # VPC & networking
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
   db_subnet_group_name    = aws_db_subnet_group.temporal.name

}

# Use your private subnets for RDS
resource "aws_db_subnet_group" "temporal" {
  name       = "temporal-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "temporal-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-sg"
  description = "Allow MySQL access from EKS"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]   # allow all EKS pods in the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "null_resource" "create_temporal_dbs" {
#   depends_on = [aws_db_instance.temporal_mysql]

#   provisioner "local-exec" {
#     command = <<EOT
#       mysql -h ${aws_db_instance.temporal_mysql.address} \
#             -u ${aws_db_instance.temporal_mysql.username} \
#             -p ${aws_db_instance.temporal_mysql.password} \
#             -e "CREATE DATABASE IF NOT EXISTS temporal; CREATE DATABASE IF NOT EXISTS temporal_visibility;"
#     EOT
#   }
# }
