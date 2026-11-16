# 策略格式与控制面说明

本目录提供一套面向华为云的**组织级 Deny 治理策略示例库**。策略只做预防性拦截，不授予权限；最终有效权限 = 身份策略授权结果与 Deny 边界的交集。控制能力分散在三个层次：

| 控制层 | 华为云承载 | 适用范围 |
|---|---|---|
| 组织级 Deny | 组织服务（Organizations）服务控制策略 SCP | 按组织单元 / 账号分发，限制账号内可执行动作 |
| 账号 / 项目级 Deny | IAM 自定义身份策略 | 条件键、资源级授权、委托主体限定 |
| 服务原生安全配置 | OBS 桶策略与公共访问阻断、DEW 密钥策略、IAM 身份提供方配置 | 承接策略 JSON 无法表达的控制 |

## IAM 5.0 身份策略 JSON 骨架

```json
{
  "Version": "5.0",
  "Statement": [
    {
      "Sid": "OptionalStatementId",
      "Effect": "Deny",
      "Action": ["<service>:<resource-type>:<operation>"],
      "Resource": ["*"],
      "Condition": { "<operator>": { "<condition-key>": "<value>" } }
    }
  ]
}
```

格式要点：

- `Version` 固定为 `5.0`；身份策略不含 `Principal` 字段。
- `Action` 为三段式 `服务名:资源类型:操作`；通配整个服务写作 `服务名:*:*`。STS 全局操作的资源类型段可为空，例如 `sts::tagSession`。
- `Resource` 为数组；资源 URN 为五段式 `服务名:region:账号ID:资源类型:资源路径`。KMS 授权项必须给出 `KeyId` 资源 URN，例如 `kms:*:*:KeyId:*`。
- `Condition` 只使用官方列出的条件键与运算符。带通配符的匹配用 `StringMatch` / `StringNotMatch`；`IfExists` 变体仅 `StringEqualsIfExists`、`StringNotEqualsIfExists`、`BoolIfExists`。
- 每个 JSON 末尾的 `_hc_note` 是仓库说明字段，附加到 IAM 前必须删除；全部 `<...>` 占位符需替换为实际值。

## 条件键速查

| 类别 | 常用键 |
|---|---|
| 全局 | `g:DomainId` `g:DomainName` `g:EnterpriseProjectId` `g:PrincipalUrn` `g:PrincipalOrgID` `g:PrincipalOrgPath` `g:ResourceOrgId` `g:ResourceOrgPath` `g:PrincipalIsService` `g:PrincipalType` `g:SecureTransport` `g:SourceAccount` `g:SourceIp` `g:SourceVpc` `g:TagKeys` `g:TokenIssueTime` `g:FederatedProvider` |
| OIDC / 联邦 | `oidc:iss` `oidc:sub` `oidc:aud` `oidc:amr` `sts:DurationTime` `sts:ExternalId` `sts:TransitiveTagKeys` `sts:AgencySessionName` |
| OBS | `obs:x-obs-acl` `obs:x-obs-server-side-encryption` `obs:TlsVersion` `obs:EpochTime` `obs:SourceIp` `obs:BucketEncrypted` `obs:versionId` `obs:prefix` |
| DEW / KMS | `kms:KeySpec` `kms:KeyUsage` `kms:KeyOrigin` `kms:GranteePrincipalType` `kms:GranteePrincipal` `kms:GrantOperations` `kms:ScheduleKeyDeletionPendingWindowInDays` `kms:EncryptionAlgorithm` `kms:RequestAlias` |

> 完整名单以 IAM 官方「全局条件键」「服务级条件键」「JSON 元素参考」为准。若某控制目标没有可直接表达的条件键，请在服务侧配置落地，见各分类 README 的「服务侧替代」小节。

## 目录索引

| 分类 | 主题 |
|---|---|
| `01-data-perimeter-guardrails/` | 可信身份 / 可信资源 / 可信网络边界 |
| `02-intra-organization-boundaries/` | 组织单元间访问限制 |
| `03-resource-access-patterns/` | 仅 HTTPS / 服务主体访问限制 |
| `04-oidc-identity-providers/` | 可信 OIDC 身份提供方白名单 |
| `05-service-specific-controls/` | OBS / DEW(KMS) / IAM 与 STS 基线 |
