variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "cloud-native-cluster"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}
