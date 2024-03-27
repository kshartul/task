resource "aws_iam_role" "terraform" {
  name = "tf-admin"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

data "aws_caller_identity" "current" {}

# assume role policy data
data "aws_iam_policy_document" "terraform_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role_policy" "manipulate_resources" {
  name   = "ManipulateAWSResources"
  role   = aws_iam_role.terraform.id
  policy = data.aws_iam_policy_document.manipulate_resources.json
}

data "aws_iam_policy_document" "manipulate_resources" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "s3:*",  
      "iam:*",
      "kms:*",
      "logs:*",
      "ec2:*",
      "eks:*",
      "autoscaling:*",
      "ssm:GetParameter",
      "dynamodb:*"
 
    ]
  }
}