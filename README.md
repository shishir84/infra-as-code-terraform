1. create IAM user as terraform-ec2-user
2. Create below policies and attach them to the terraform-ec2-user IAM user.

a. terraform-state-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TerraformStateAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::wingspan-infra-terraform-state-bucket",
                "arn:aws:s3:::wingspan-infra-terraform-state-bucket/*"
            ]
        }
    ]
}

b. iam-terraform-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "kafka.amazonaws.com",
                        "elasticache.amazonaws.com",
                        "ec2.amazonaws.com",
                        "eks.amazonaws.com",
                        "eks-nodegroup.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole",
                "iam:DeleteRolePolicy",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole"
            ],
            "Resource": "*"
        }
    ]
}

c. sg-terraform-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSecurityGroupManagement",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeSecurityGroups",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupEgress"
            ],
            "Resource": "*"
        }
    ]
}


d. ec2-terraform-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2BasicAccess",
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances",
                "ec2:RebootInstances",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:CreateVolume",
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:DeleteVolume",
                "ec2:ModifyInstanceAttribute",
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes",
                "ec2:CreateVolume",
                "ec2:AttachVolume"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMPassRoleForEC2",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Sid": "KeyPairAccess",
            "Effect": "Allow",
            "Action": [
                "ec2:ImportKeyPair",
                "ec2:DeleteKeyPair",
                "ec2:DescribeKeyPairs"
            ],
            "Resource": "*"
        }
    ]
}

e. efs-terraform-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2BasicAccess",
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances",
                "ec2:RebootInstances",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:CreateVolume",
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:DeleteVolume",
                "ec2:ModifyInstanceAttribute",
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes",
                "ec2:CreateVolume",
                "ec2:AttachVolume"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMPassRoleForEC2",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Sid": "KeyPairAccess",
            "Effect": "Allow",
            "Action": [
                "ec2:ImportKeyPair",
                "ec2:DeleteKeyPair",
                "ec2:DescribeKeyPairs"
            ],
            "Resource": "*"
        }
    ]
}

f. eks-terraform-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:CreateCluster",
                "eks:DeleteCluster",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:UpdateClusterConfig",
                "eks:CreateNodegroup",
                "eks:DeleteNodegroup",
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:PassRole",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "ec2:CreateSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "autoscaling:*",
                "eks:TagResource"
            ],
            "Resource": "*"
        }
    ]
}

g. elasticahe-redis-terraform-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticache:CreateCacheCluster",
                "elasticache:DeleteCacheCluster",
                "elasticache:DescribeCacheClusters",
                "elasticache:ModifyCacheCluster",
                "elasticache:AddTagsToResource",
                "elasticache:RemoveTagsFromResource",
                "elasticache:CreateCacheSubnetGroup",
                "elasticache:DescribeCacheSubnetGroups",
                "elasticache:ListTagsForResource",
                "elasticache:DeleteCacheSubnetGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeVpcs"
            ],
            "Resource": "*"
        }
    ]
}

h. kms-terraform-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "kms:EnableKeyRotation",
                "kms:Decrypt",
                "kms:GetKeyPolicy",
                "kms:ListResourceTags",
                "kms:ListGrants",
                "kms:TagResource",
                "kms:Encrypt",
                "kms:GetKeyRotationStatus",
                "kms:ScheduleKeyDeletion",
                "kms:ListAliases",
                "kms:RevokeGrant",
                "kms:GenerateDataKey",
                "kms:CreateAlias",
                "kms:DescribeKey",
                "kms:CreateKey",
                "kms:CreateGrant",
                "kms:DeleteAlias"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey*"
            ],
            "Resource": "*"
        }
    ]
}

i. msk-terraform-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "kafka:DescribeClusterV2",
                "kafka:ListClustersV2",
                "kafka:TagResource",
                "kafka:CreateCluster",
                "kafka:ListClusters",
                "kafka:ListNodes",
                "kafka:DeleteCluster",
                "kafka:DescribeCluster",
                "kafka:GetBootstrapBrokers",
                "kafka:UntagResource"
            ],
            "Resource": "*"
        }
    ]
}

j. opensearch-terraform-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "es:DescribeDomainConfig",
                "es:DescribeElasticsearchDomainConfig",
                "es:CreateDomain",
                "es:AddTags",
                "es:RemoveTags",
                "es:DescribeDomain",
                "es:UpdateDomainConfig",
                "es:ListDomainNames",
                "es:DeleteDomain",
                "es:ListTags"
            ],
            "Resource": "*"
        }
    ]
}

k. rds-terraform-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowRDSFullManagement",
            "Effect": "Allow",
            "Action": [
                "rds:CreateDBInstance",
                "rds:DescribeDBInstances",
                "rds:DeleteDBInstance",
                "rds:ModifyDBInstance",
                "rds:CreateDBSubnetGroup",
                "rds:DescribeDBSubnetGroups",
                "rds:AddTagsToResource",
                "rds:ListTagsForResource",
                "rds:DescribeDBParameterGroups",
                "rds:DescribeEngineDefaultParameters",
                "rds:DeleteDBSubnetGroup"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowSupportingEC2ActionsForRDS",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups"
            ],
            "Resource": "*"
        }
    ]
}

l. s3-terraform-policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:PutBucketVersioning",
                "s3:GetBucketVersioning",
                "s3:PutBucketTagging",
                "s3:GetBucketTagging",
                "s3:PutBucketAcl",
                "s3:GetBucketAcl"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
