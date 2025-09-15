resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  #cluster_endpoint_public_access  = true
  #cluster_endpoint_private_access = true

  vpc_config {
    subnet_ids = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    endpoint_public_access        = true
    endpoint_private_access       = true

  }
}
