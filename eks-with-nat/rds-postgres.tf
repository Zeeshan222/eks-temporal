# resource "aws_db_instance" "temporal" {
#   allocated_storage    = 20
#   engine               = "postgres"
#   engine_version       = "15.9"  # Use a supported version
#   instance_class       = "db.t3.micro"
#   identifier           = "temporal"
#   username             = "admin1234"
#   password             = "admin1234"
#   skip_final_snapshot  = true
#   publicly_accessible  = true
# }
