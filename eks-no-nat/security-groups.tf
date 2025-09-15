# Fetch all instances in the node group
data "aws_instances" "eks_nodes" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [var.cluster_name]
  }

  filter {
    name   = "tag:eks:nodegroup-name"
    values = ["system-nodes"]
  }
}

# For each instance, get details (including SGs)
data "aws_instance" "eks_node" {
  for_each = toset(data.aws_instances.eks_nodes.ids)
  instance_id = each.value
}

# Collect all SG IDs
locals {
  node_group_sg_ids = toset(flatten([
    for inst in data.aws_instance.eks_node : inst.vpc_security_group_ids
  ]))
}
# SG for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-sg"
  description = "Allow nodes to connect to VPC endpoints"
  vpc_id      = aws_vpc.this.id

  # Allow HTTPS from worker nodes
  ingress {
    description = "Allow nodes to connect to VPC endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = local.node_group_sg_ids
  }

  # Egress to anywhere (or restrict if you want)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eks_nodes" {
  name        = "eks-nodes-sg"
  description = "Security group for EKS nodes and pods"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr, var.secondary_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
