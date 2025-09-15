# data "aws_eks_cluster_auth" "this" {
#   name = var.cluster_name
# }

# provider "helm" {
#   kubernetes = {
#     host                   = aws_eks_cluster.this.endpoint
#     cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.this.token
#   }
# }



# resource "helm_release" "temporal" {
#   name       = "temporal"
#   repository = "https://go.temporal.io/helm-charts"
#   chart      = "temporal"
#   namespace  = "temporal"
#   create_namespace = true

#   values = [
#     templatefile("${path.module}/temporal-values.yaml", {
#       rds_endpoint = aws_db_instance.temporal_mysql.address
#       db_username  = var.db_username
#       db_password  = var.db_password
#     })
#   ]
   
#    depends_on = [
#     aws_eks_cluster.this,
#     aws_eks_node_group.system_nodes, # if you have a node group
#   ]
# }
  
 
  
 