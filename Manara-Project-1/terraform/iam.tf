 # IAM — EC2 Role for Systems Manager Session Manager
 # Grants EC2 instances the `AmazonSSMManagedInstanceCore` policy so
# you can connect via Session Manager without SSH keys or open port 22.

 # IAM Role
 resource "aws_iam_role" "ec2_role" {
  name = "${local.name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = "${local.name}-ec2-role" })
}

 # Attach the AWS-managed SSM policy
 resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

 # Instance Profile (required so EC2 can assume the role)
 resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
