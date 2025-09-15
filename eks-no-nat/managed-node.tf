resource "aws_iam_role" "node_group_role" {
  name = "${var.cluster_name}-nodegroup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_group_worker" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_group_cni" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_group_ecr" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}




resource "aws_eks_node_group" "system_nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "system-nodes"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 3
    min_size     = 1
    max_size     = 7
  }

  instance_types = ["m7i-flex.large"]
  force_update_version = true
}


data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
  
}

provider "kubernetes" {
  alias                  = "eks"
  host = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.this.token

}

resource "null_resource" "apply_eniconfig" {
  depends_on = [aws_eks_cluster.this]

  provisioner "local-exec" {
    command = <<EOT
    aws eks update-kubeconfig --name eks-temporal --region eu-north-1
    kubectl apply -f - <<EOF
    apiVersion: crd.k8s.amazonaws.com/v1alpha1
    kind: ENIConfig
    metadata:
      name: secondary-eniconfig
    spec:
      subnet: ${aws_subnet.secondary[0].id}
      securityGroups:
        - ${aws_security_group.eks_nodes.id}
    EOF
    EOT
  }
}


# resource "kubernetes_manifest" "eni_config" {
#   depends_on = [aws_eks_cluster.this, aws_eks_node_group.system_nodes]
  
#    provider = kubernetes.eks
#   manifest = {
#     apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
#     kind       = "ENIConfig"
#     metadata = {
#       name      = "secondary-eniconfig"
#     }
#     spec = {
#       subnet = aws_subnet.secondary[0].id
#       securityGroups = [aws_security_group.eks_nodes.id]
#     }
#   }
# }