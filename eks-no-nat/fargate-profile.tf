resource "aws_eks_fargate_profile" "this" {
  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "temporal-fp"
  pod_execution_role_arn = aws_iam_role.fargate_pod.arn
  subnet_ids             = aws_subnet.private[*].id

 
 
 
selector {
    namespace = "kube-system"
    labels = {
      "k8s-app" = "kube-dns"
    }
  }

  tags = {
    Name = "coredns-fargate-profile"
  }
}

