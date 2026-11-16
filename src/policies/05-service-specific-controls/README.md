# 服务特定控制（Service-specific Controls）

**控制目标**：为 OBS、DEW（KMS）、IAM / STS 设定基线安全要求，拦截危险操作与不合规配置。

## 目录内容

| 组 | 文件数 | 覆盖内容 |
|---|---|---|
| OBS | 7 | 禁止公开 ACL / 公共访问阻断变更 / 强制 TLS 版本 / 强制 KMS 服务端加密 / 保护桶与对象不被删除 / 限制长期访问凭据 |
| DEW（KMS） | 4 | 禁止弱密钥创建 / 限制密钥删除主体 / 限制授权创建 / 删除等待期下限 |
| IAM / STS | 5 | 身份提供方删除保护 / 未认证 OIDC 访问拦截 / 会话标签保护 / 联邦会话约束 |
| 简化模板 | 2 | `kms-delete.json`、`obs-tls-delete.json` |

> 每个 JSON 的 `_hc_note` 记录了该策略采用的官方授权项、条件键与服务侧替代说明；附加到 IAM 前请删除该字段并替换占位符。

## 代表策略

**OBS：禁止写入公开 ACL**

```json
{
  "Version": "5.0",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": ["obs:bucket:putBucketAcl", "obs:object:putObjectAcl"],
      "Resource": ["obs:*:*:bucket:*", "obs:*:*:object:*/*"],
      "Condition": {
        "StringMatch": { "obs:x-obs-acl": ["public-read", "public-read-write"] }
      }
    }
  ]
}
```

**DEW：仅允许特权委托删除密钥**

```json
{
  "Version": "5.0",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": ["kms:cmk:scheduleKeyDeletion"],
      "Resource": ["kms:*:*:KeyId:*"],
      "Condition": {
        "StringNotEquals": { "g:PrincipalUrn": "iam::*:agency:<PRIVILEGED_AGENCY>" }
      }
    }
  ]
}
```

**IAM / STS：限制 OIDC 未认证访问**

```json
{
  "Version": "5.0",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": ["sts:agencies:assumeWithOIDC"],
      "Resource": ["*"],
      "Condition": {
        "Null": { "oidc:sub": "true", "oidc:iss": "true" },
        "StringNotEqualsIfExists": { "g:PrincipalType": "<TRUSTED_PRINCIPAL_TYPE>" }
      }
    }
  ]
}
```

## 服务侧替代

| 控制目标 | 策略可表达部分 | 需服务侧配置承接 |
|---|---|---|
| 账号级公共访问阻断 | 桶级 `obs:bucket:deleteBucketPublicAccessBlock` 拒绝移除 | OBS 控制台的账号级公共访问阻断全局设置 |
| 新桶 ACL 强制私有 | `obs:x-obs-acl` 拒绝公开取值 | 桶创建流程统一由 IaC 下发，禁止手工建桶 |
| 客户自备密钥加密 | `obs:x-obs-server-side-encryption` 强制取值 `kms` | 桶默认加密配置 + 组织 SCP 兜底 |
| 长期有效的预签名 URL | `g:TokenIssueTime` 要求使用临时安全凭证 | 签发侧限制 `Expires` 上限并用短时效临时凭证生成 URL；OBS 无签名时效条件键 |
| 密钥删除保护 | `kms:ScheduleKeyDeletionPendingWindowInDays` 约束删除等待期 | DEW 密钥策略限制删除主体，并开启 CTS 密钥操作审计 |
| 匿名身份来源 | `oidc:sub` / `oidc:iss` 非空校验 + `g:PrincipalType` | IAM 仅配置 OIDC 身份提供方与信任委托，不开放匿名身份来源 |
| 授权仅限云服务主体 | `kms:GranteePrincipalType` / `kms:GranteePrincipal` / `kms:GrantOperations` | 密钥策略中显式列出被授权方 |
| 资源归属边界 | `g:EnterpriseProjectId` / `g:DomainName` | 企业项目按组织单元划分并统一打标签 |

> 授权项、条件键与运算符均以 IAM 官方授权参考为准；`Version` 固定 `5.0`，`Action` 为三段式，`Resource` 为数组。个别条件键取值（如 `kms:KeySpec`、`kms:GranteePrincipalType`）请按当前服务版本 API 文档核对后替换占位符。
