resource "aws_eks_cluster" "eks_cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_master_role.arn
  version  = local.cluster_version

  vpc_config {
    subnet_ids = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id,
      aws_subnet.public_3.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-policy,
  ]

  provisioner "local-exec" {
    command = <<EOT
    until curl -k -s ${aws_eks_cluster.eks_cluster.endpoint}/healthz >/dev/null; do sleep 4; done
  EOT
  }
}
