# 组织内边界（Intra-organization Boundaries）

**控制目标**：限定组织单元（OU）/ 账号之间的资源访问范围，拒绝来自其它组织路径的主体访问本组织资源。

## 华为云落地方式

- **组织服务 SCP**：按组织单元 / 账号附着 Deny 语句，作用范围覆盖该组织单元下所有账号。
- **IAM 自定义身份策略**：`g:PrincipalOrgID`、`g:PrincipalOrgPath`、`g:ResourceOrgId`、`g:ResourceOrgPath`、`g:DomainId`、`g:DomainName` 表达组织归属与账号边界。
- 组织路径带通配时用 `StringMatch` / `StringNotMatch`（支持 `*`、`?`）；主体 URN 例外用 `iam::*:agency:<PRIVILEGED_AGENCY>` 形式书写。

## 本目录策略

| 文件 | 控制内容 |
|---|---|
| `org-unit-deny-except-same-path.json` | 资源归属指定组织路径时，拒绝非同路径主体与非特权委托的访问 |
| `org-unit-deny-specific-resources.json` | 覆盖 OBS / DEW / CSMS / DMS / GaussDB / LTS / SWR 等多服务的组织路径边界 |
| `org-boundary.json` | 按账号域名 `g:DomainName` 划定资源边界的简化模板 |

## 代表策略

```json
{
  "Version": "5.0",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": ["obs:*:*", "kms:*:*", "ecs:*:*"],
      "Resource": ["*"],
      "Condition": {
        "StringNotEquals": { "g:DomainName": "<TRUSTED_DOMAIN_NAME>" }
      }
    }
  ]
}
```

**服务侧替代**：`g:ResourceOrgPath` 一类组织路径条件键需要组织服务已开启并正确回填组织信息；若环境未启用组织服务，请改用 `g:DomainId` / `g:EnterpriseProjectId` 表达边界，或直接按组织单元分发多份 SCP。
