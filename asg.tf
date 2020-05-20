resource "aws_autoscaling_group" "eks_asg" {
  name                 = "EKS cluster nodes"
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.eks_lc.id
  max_size             = 2
  min_size             = 2

  vpc_zone_identifier = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id,
    aws_subnet.public_3.id,
  ]

  tag {
    key                 = "Name"
    value               = "${local.base_name}-nodes"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${local.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}

locals {
  userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh "${aws_eks_cluster.eks_cluster.name}"
USERDATA
}

data "aws_ami" "eks_node" {
  most_recent = true
  owners      = ["602401143452"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-*"]
  }
}

resource "aws_launch_configuration" "eks_lc" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.eks_node_role_profile.id
  image_id                    = data.aws_ami.eks_node.image_id
  instance_type               = "t3.small"
  name_prefix                 = "eks-node"
  key_name                    = local.key_name
  enable_monitoring           = false

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  security_groups = [
    aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id,
  ]
  user_data_base64 = base64encode(local.userdata)

  lifecycle {
    create_before_destroy = true
  }

}
