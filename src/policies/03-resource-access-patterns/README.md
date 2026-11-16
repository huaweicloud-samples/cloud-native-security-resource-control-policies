# 资源访问模式限制（Resource Access Patterns）

**控制目标**：强制加密传输、限制服务主体代客访问，形成统一的访问模式基线。

## 华为云落地方式

- **强制 TLS**：`g:SecureTransport` 配合 `BoolIfExists` 拒绝非加密请求；最低 TLS 版本用 `obs:TlsVersion` 配合 `NumberLessThan` 设定。
- **服务主体访问**：`g:PrincipalIsService`、`g:PrincipalServiceName`、`g:AssumedByService`、`g:CalledVia` 判定调用链；`g:PrincipalOrgID` / `g:SourceAccount` 限定发起方归属。
- 条件键可能缺失时，用 `IfExists` 变体或 `Null` 明确处理，避免把无该键的请求整批放行或整批拒绝。

## 本目录策略

| 文件 | 控制内容 |
|---|---|
| `https-only-access.json` | 拒绝非 TLS 请求，覆盖 OBS / DEW / CSMS / DMS / GaussDB / LTS / SWR 等服务 |
| `service-principal-access-control.json` | 限制组织外服务主体代客访问 |

## 代表策略

```json
{
  "Version": "5.0",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": ["obs:*:*"],
      "Resource": ["*"],
      "Condition": { "BoolIfExists": { "g:SecureTransport": "false" } }
    }
  ]
}
```

**服务侧替代**：OBS 桶策略可直接拒绝非 HTTPS 请求并设置最低 TLS 版本；CDN / APIG 侧可强制 HTTPS 回源与访问。策略 JSON 与服务侧配置建议同时启用，避免仅靠单层拦截。
