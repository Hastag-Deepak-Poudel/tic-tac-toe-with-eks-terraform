variable "environment" {
  type        = string
  description = "The deployment environment"
  default     = "dev" 
}

variable "eks_cluster_name" {
  type        = string
  description = "The custom name for the EKS cluster"
  default     = "my-own-cluster"
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC"
  default     = "my-eks-vpc"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}