terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.42.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AK"
  secret_key = "SAK"
}

resource "aws_iam_user" "nubeera_user" {
    name = "nubeera_user_1"
}

resource "aws_iam_access_key" "nubeera_user_access_key" {
    user =  aws_iam_user.nubeera_user.name
}

resource "random_pet" "pet_name" {
    length = 3
    separator = "_"
}

resource "aws_s3_bucket" "pet_bucket" {
  bucket ="${random_pet.pet_name.id}-bucket"
  acl = "private"

  tags = {
    "Name" = "My Bucket"
    Environment = "Dev"
  }
}

#Create IAM Policy Document
data "aws_iam_policy_document" "s3_policy" {
    statement {
        actions = ["s3:ListAllMyBuckets"]
        resources = ["arn:aws:s3:::*"]
        effect = "Allow"
    }
    statement {
        actions = ["s3:*"]
        resources = [aws_s3_bucket.pet_bucket.arn]
        effect = "Allow"
    }
}

#Attach Policy Document to newly created Policy
resource "aws_iam_policy" "s3_bucket_policy" {
    name = "${random_pet.pet_name}-policy"
    description = "S3 Bucket Listing all user policy"
    policy = data.aws_iam_policy_document.s3_policy.json
}

#Create IAM Group
resource "aws_iam_group" "nubeera_admin_group" {
    name ="grp-tfadmin"
}

# Attach Group to User Membership
resource "aws_iam_group_membership" "team" {
    name = "tf-testing-group"
    users = [
        aws_iam_user.nubeera_user.name,        
    ]
    group  = aws_iam_group.nubeera_admin_group.nname
}