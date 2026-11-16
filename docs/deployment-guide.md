# 使用指导书

本指导书说明如何使用 `cloud-native-security-resource-control-policies` 策略参考库。

## 1. 前置条件

- 华为云账号（目标组织/管理面）
- 具备组织服务（Organization）/ IAM 权限的用户（如需部署 SCP / 自定义策略）
- 目标云资源（OBS / DEW / IAM 等）已在受管项目/账号下

## 2. 策略库结构

```text
src/policies/
├── 00-policy-format.md                     # 格式与映射说明
├── 01-data-perimeter-guardrails/           # 数据外边界
├── 02-intra-organization-boundaries/       # 组织内边界
├── 03-resource-access-patterns/            # 访问模式
├── 04-oidc-identity-providers/             # 可信 OIDC
└── 05-service-specific-controls/           # 服务特定控制
```

## 3. 使用流程

1. 选择目标控制类别（例如数据外边界 → `01-data-perimeter-guardrails/`）
2. 阅读该目录 README，理解「源意图 → 华为云实现 + 差异」
3. 复制代表策略 JSON，将 `${...}` 占位替换为实际项目/角色/组织
4. 在**非生产组织单元/项目**先用目标服务策略验证影响（Deny 可能阻断合法操作）
5. 渐进推广：先小范围 OU，再扩大

## 4. 部署示例（可选 IaC）

策略可通过组织服务控制策略（SCP）或 IAM 自定义策略下发；如需 IaC 管理，参考：

```hcl
resource "huaweicloud_identity_policy" "perimeter" {
  name    = "data-perimeter-guardrail"
  content = jsonencode({
    Version = "1.1"
    Statement = [{
      Effect = "Deny"
      Action = ["obs:*", "kms:*"]
      Resource = ["*"]
      Condition = { "StringNotEquals" = { "g:DomainName" = "trusted.example.com" } }
    }]
  })
}
```

> 说明：`huaweicloud_identity_policy` 为 IAM 自定义策略；组织级 SCP 请根据组织服务控制台/API 配置。示例见 `infra/`（可选）。

## 5. 校验与回滚

- 修改后先观察审计日志一段时间（无意外 Deny 记录）
- 保留上次可用策略副本，异常时回滚到副本
