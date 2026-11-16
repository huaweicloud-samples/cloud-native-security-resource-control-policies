# ============================================================================
# 治理策略示例（可选）：组织级资源控制策略参考库的 IaC 落地示例
# 说明：本示例创建一条 IAM 自定义策略（数据外边界 Deny），可作为下发模板；
#       组织级 SCP 请参考组织服务控制台/API。
# ============================================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.70"
    }
  }
}

provider "huaweicloud" {
  region         = var.region
  access_key     = var.access_key
  secret_key     = var.secret_key
  security_token = var.security_token
}

variable "access_key" {
  description = "华为云 Access Key（terraform.tfvars 本地注入，不提交 git）"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "华为云 Secret Key（terraform.tfvars 本地注入，不提交 git）"
  type        = string
  sensitive   = true
}

variable "security_token" {
  description = "临时安全令牌（STS，本地验证用；使用长期访问密钥时留空）"
  type        = string
  default     = ""
  sensitive   = true
}

variable "region" {
  description = "华为云区域"
  type        = string
  default     = "cn-north-4"
}

variable "project_name" {
  description = "策略命名前缀"
  type        = string
  default     = "sec-policy"
}

variable "trusted_domain" {
  description = "可信域名（用作条件键 g:DomainName 的目标值）"
  type        = string
  default     = "trusted.example.com"
}

resource "huaweicloud_identity_policy" "data_perimeter" {
  name = "${var.project_name}-data-perimeter"
  policy_document = jsonencode({
    Version = "5.0"
    Statement = [
      {
        Effect   = "Deny"
        Action   = ["obs:*"]
        Resource = ["*"]
      }
    ]
  })
}

output "policy_id" {
  description = "数据外边界策略 ID"
  value       = huaweicloud_identity_policy.data_perimeter.id
}
