# 可信 OIDC 身份提供方限制

**控制目标**：仅允许列入白名单的 OIDC 签发方（`iss`）、受众（`aud`）与主体（`sub`）换取委托临时凭证。

## 华为云落地方式

- 在 IAM 创建 OIDC 身份提供方，配置签发方 URL、客户端 ID 与指纹；委托信任策略限定可信主体。
- 身份策略以 `sts:agencies:assumeWithOIDC` 为拦截点，配合 `oidc:iss` / `oidc:sub` / `oidc:aud` / `oidc:amr`。
- `g:FederatedProvider` 按联邦身份提供方名称拒绝内置或公共身份来源。
- 会话时长用 `sts:DurationTime` 配合 `NumberGreaterThan` 限制；主体声明缺失时用 `Null` 拒绝。

## 本目录策略

| 文件 | 控制内容 |
|---|---|
| `Deny-built-in-web-identity-providers.json` | 按 `g:FederatedProvider` 拒绝公共身份提供方 |
| `GitHub-Actions.json` | 按 `oidc:iss` + `oidc:sub` 双重限定 CI 工作流主体 |
| `Shared-Issuers.json` | 签发方 / 主体 / 受众三类白名单模板 |

## 代表策略

```json
{
  "Version": "5.0",
  "Statement": [
    {
      "Sid": "DenyUntrustedOIDCIssuer",
      "Effect": "Deny",
      "Action": ["sts:agencies:assumeWithOIDC"],
      "Resource": ["*"],
      "Condition": {
        "StringNotEqualsIfExists": { "oidc:iss": "<TRUSTED_ISSUER_URL>" },
        "Null": { "oidc:iss": "false" }
      }
    }
  ]
}
```

**服务侧替代**：`oidc:aud` 的白名单取值由 IAM 身份提供方的客户端 ID 配置决定，策略与身份提供方配置需保持一致；外部 CI 平台的工作流主体格式（`oidc:sub`）按各平台实际声明填写。
