# 数据外边界守护（Data Perimeter Guardrails）

**控制目标**：只允许可信身份、从可信网络、访问可信资源。以 Deny 语句划定边界，不授予任何权限。

本目录为概念说明目录；可直接使用的策略见 `02` ～ `05` 分类。

## 华为云落地方式

| 边界 | 实现方式 |
|---|---|
| 可信身份 | `g:PrincipalUrn` / `g:PrincipalType` / `g:PrincipalOrgID` / `g:PrincipalTag/<key>` 限定委托、用户与组织归属 |
| 可信资源 | `Resource` 五段式 URN 收敛范围；`g:ResourceOrgId` / `g:ResourceOrgPath` / `g:ResourceAccount` 限定资源归属 |
| 可信网络 | `g:SourceIp` / `g:SourceVpc` / `g:SourceVpce` / `g:VpcSourceIp` 配合 `IpAddress` / `NotIpAddress`；服务侧再叠加 VPC 终端节点策略 |

## 代表策略

```json
{
  "Version": "5.0",
  "Statement": [
    {
      "Sid": "DenyOutsideTrustedNetwork",
      "Effect": "Deny",
      "Action": ["obs:*:*", "kms:*:*"],
      "Resource": ["*"],
      "Condition": {
        "NotIpAddress": { "g:SourceIp": ["<TRUSTED_CIDR>"] },
        "StringNotEqualsIfExists": { "g:PrincipalOrgID": "<TRUSTED_ORG_ID>" }
      }
    }
  ]
}
```

> 同一 `Condition` 内多个运算符是「与」关系：只有当请求既不在可信网段、主体组织也不匹配时才触发 Deny。若要对两类条件分别拦截，请拆成多条 Statement。

**服务侧替代**：跨账号的资源共享边界建议用组织服务 SCP 按组织单元分发；OBS 侧配合桶策略与公共访问阻断，避免仅依赖 IP 条件。组织路径类条件键依赖组织服务已启用并正确回填组织信息。
