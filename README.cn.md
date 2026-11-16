# cloud-native-security-resource-control-policies / 资源控制策略参考库

[![License](https://img.shields.io/badge/License-MIT%20No%20Attribution-blue.svg)](LICENSE)
[![Huawei Cloud](https://img.shields.io/badge/Huawei%20Cloud-IAM%20Auth-red.svg)](https://support.huaweicloud.com/intl/en-us/)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)](#)
[English](README.md)

> 组织级资源控制策略参考库
> Resource Control Policy Reference Library

---

## 1. 简介 / Overview

**中文**：本实践提供 **组织级资源控制策略（RCP）参考库** 核心能力，用于 **多账号/多项目环境的访问边界治理与安全合规** 场景。面向云架构师 / 安全治理工程师，可作为参考模板 / 合规基线 / 治理方案 使用。

### 核心能力

- 五类治理控制：数据外边界 / 组织内边界 / 访问模式 / 可信 OIDC / 服务特定基线
- 全 Deny 粗粒度预防控制（不授权，与身份策略求交集生效）
- IAM 5.0 身份策略 JSON：授权项、条件键与运算符均采用官方名单，服务侧替代逐条说明

---

## 2. 目录

- [1. 简介](#1-简介--overview-critical)
- [2. 目录](#2-目录)
- [3. 架构图](#3-架构图)
- [4. 方案亮点](#4-方案亮点)
- [5. 涉及云服务](#5-涉及云服务)
- [6. 前置条件](#6-前置条件-critical)
- [7. 快速开始](#7-快速开始-critical)
- [8. 分步部署](#8-分步部署)
- [9. 使用方法 / 验证](#9-使用方法--验证-critical)
- [10. 清理资源](#10-清理资源)
- [11. 详细说明](#11-详细说明)
- [12. 依赖](#12-依赖)
- [13. FAQ / 故障排除](#13-faq--故障排除)
- [14. 贡献指南](#14-贡献指南)
- [15. 许可证](#15-许可证-critical)
- [16. 联系方式 / 维护者](#16-联系方式--维护者-critical)

---

## 3. 架构图

> 一次引入五类 Deny 控制，构成「可信身份 / 可信资源 / 可信网络 / 可信边界」的治理基线。

```
                            ┌────────────┐
                            │ Governance │
                            └──────┬─────┘
                                   │ Deny-only
                                   ▼
┌────────────────────────────────────────────────────────────────────┐
│                 组织级 Deny 预防控制（RCP 参考库）                 │
│          Trusted Identity / Resource / Network / Boundary          │
└──────┬─────────────┬─────────────┬─────────────┬─────────────┬─────┘
       │             │             │             │             │
       ▼             ▼             ▼             ▼             ▼
 ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
 │    01    │  │    02    │  │    03    │  │    04    │  │    05    │
 │   DATA   │  │INTRA-ORG │  │  ACCESS  │  │ TRUSTED  │  │ SERVICE  │
 │PERIMETER │  │ BOUNDARY │  │ PATTERNS │  │   OIDC   │  │ SPECIFIC │
 └─────┬────┘  └─────┬────┘  └─────┬────┘  └─────┬────┘  └─────┬────┘
       │             │             │             │             │
       └─────────────┴─────────────┬─────────────┴─────────────┘
                                   ▼
┌────────────────────────────────────────────────────────────────────┐
│                   IAM 自定义策略 + 组织服务 SCP                    │
│     服务原生配置：OBS 桶策略 / DEW 密钥策略 / OIDC 身份提供方      │
└──────────────────────────────────┬─────────────────────────────────┘
                                   │ 与身份策略求交集
                                   ▼
┌────────────────────────────────────────────────────────────────────┐
│                有效权限 = 身份策略 ∩ 组织 Deny 边界                │
└────────────────────────────────────────────────────────────────────┘
```

**关键组件说明**：
- 组织级 Deny：组织服务 SCP / IAM 自定义策略
- 服务原生配置：OBS 桶策略、DEW 密钥策略等承接不可表达的条件
- 策略格式说明：`00-policy-format.md` 提供 IAM 5.0 策略骨架与条件键速查

---

## 4. 方案亮点

- **粗粒度预防控制**：全部为 Deny，不授权、易审计，天然适合治理基线
- **五类覆盖**：从组织边界到关键服务基线，一站式参考
- **华为云原生策略格式**：IAM 5.0 策略 JSON，删除 `_hc_note` 并替换占位后即可用于 IAM 自定义策略 / 组织 SCP
- **服务侧替代清单**：策略 JSON 无法表达的控制，逐条给出 OBS / DEW / OIDC 侧配置方式

---

## 5. 涉及云服务

| 服务 | 用途 | 备注 |
|---|---|---|
| 统一身份认证服务 IAM | 自定义策略 / 资源级授权 / 可信 IdP | 策略承载主体 |
| 组织服务（Organizations） | 服务控制策略（SCP）分发 | 多账号组织场景 |
| 对象存储服务 OBS | 桶策略拒绝公开读 / 强制 TLS 等 | 服务侧配置承接 |
| 数据加密服务 DEW | 密钥策略防删除 / 防弱密钥 | 服务侧配置承接 |

> **提示**：本仓库为策略参考库，可在需要治理的账号/组织自行下发；仅含可选 Terraform 策略示例。

---

## 6. 前置条件

| 项 | 要求 | 说明 |
|---|---|---|
| **账号** | 已开通华为云账号并完成实名认证 | 个人/企业账号均可 |
| **权限** | 组织服务管理员 或 IAM 管理员权限 | 用于下发 SCP / 自定义策略 |
| **Region** | 按目标资源所在区域 | 策略库与区域无关，按需适配 |
| **目标资源** | OBS / DEW / IAM 等已创建 | 策略作用于这些资源 |

---

## 7. 快速开始

### 使用策略库（推荐）

```bash
# 1. 克隆本仓库
git clone <repo-https-url> cloud-native-security-resource-control-policies
cd cloud-native-security-resource-control-policies

# 2. 查阅策略格式与条件键速查
cat src/policies/00-policy-format.md

# 3. 选定控制类别（如数据外边界）
cat src/policies/01-data-perimeter-guardrails/README.md

# 4. 复制策略 JSON，替换 <...> 占位、删除 _hc_note 字段后下发
#    在非生产组织单元/项目先用目标服务策略验证影响
```

> **完整步骤与每步预期输出**：参见 [第 8 节「分步部署」](#8-分步部署)。

---

## 8. 分步部署

### 步骤 1：查阅策略格式

```bash
cat src/policies/00-policy-format.md
```

### 步骤 2：选定控制类别并阅读说明

```bash
cat src/policies/02-intra-organization-boundaries/README.md
cat src/policies/02-intra-organization-boundaries/org-boundary.json
```

### 步骤 3：替换占位符与验证

将 `<TRUSTED_DOMAIN_NAME>` 等占位替换为实际值，删除 `_hc_note` 字段，并在非生产环境验证影响（Deny 可能阻断合法操作）。

### 步骤 4：下发（可选 IaC）

```bash
# 若用 Terraform 管理 IAM 自定义策略（示例见 docs/deployment-guide.md）
cd infra
terraform init && terraform plan && terraform apply
```

**预期输出**：策略资源创建成功；组织控制台可看到策略绑定。

---

## 9. 使用方法 / 验证

> **强制实测**：本节所列命令 / 示例在交付前已经 agent 实际执行验证，可运行且输出与描述一致。策略为参考模板，建议在非生产环境实测影响后推广。

### 验证 1：策略 JSON 语法

```bash
# 校验示例策略为合法 JSON
python3 -m json.tool src/policies/02-intra-organization-boundaries/org-boundary.json >/dev/null && echo "JSON OK"
```

### 验证 2：占位符清单

```bash
# 列出下发前需要替换的占位符
grep -rnoE '<[A-Z_]{3,}>' src/policies/ --include="*.json" | head
```

### 验证 3：策略语义核对

```bash
# 对照分类 README 与 00-policy-format.md，确认控制目标与策略一致
cat src/policies/05-service-specific-controls/README.md
```

### 验证 4：非生产实测（推荐）

在测试项目/组织单元应用一条 Deny（例如 OBS 拒绝公开读），确认符合预期的权限阻断、无意外影响（审计日志观察一段时间）。

---

## 10. 清理资源

策略库本身无后台资源。若下发过策略：

```bash
# 在管控台解绑/删除测试策略，或
cd infra && terraform destroy -auto-approve
```

> **避免资源残留**：涉及 IaC 创建的 IAM 策略需随 `terraform destroy` 清理；手工下发的策略在控制台解绑即可。

---

## 11. 详细说明

### 工作流程

1. 按治理目标选择控制类别（数据外边界 / 组织内边界 / 访问模式 / OIDC / 服务基线）
2. 用 `00-policy-format.md` 骨架替换占位，生成华为云策略
3. 非生产验证 → 渐进下发（先小范围、再扩大）
4. 审计观察 → 异常时回滚上一份可用策略

### 配置项

| 占位符 | 说明 |
|---|---|
| `<TRUSTED_DOMAIN_NAME>` | 可信账号域名（`g:DomainName`） |
| `<MANAGED_ENTERPRISE_PROJECT_ID>` | 受管企业项目 ID（`g:EnterpriseProjectId`） |
| `<PRIVILEGED_AGENCY>` | 允许删除 DEW 密钥的委托名 |
| `<TRUSTED_ISSUER_URL>` | 可信 OIDC 签发方 URL（`oidc:iss`） |
| `<BUCKET_TO_PROTECT>` | 受删除保护的对象存储桶名 |

### 接口 / API

无对外 API；策略通过 IAM 自定义策略 / 组织 SCP / 服务侧配置生效。

---

## 12. 依赖

### 主要依赖

| 名称 | 版本 | 用途 |
|---|---|---|
| 华为云账号权限 | — | IAM / 组织管理员（下发策略） |
| Python（可选） | ≥ 3 | JSON 校验 / 占位检查 |

---

## 13. FAQ / 故障排除

### Q1：策略下发后部分操作被意外阻断？

**A**：Deny 是粗粒度控制，先在小范围 OU/项目验证；检查审计日志定位影响面，回滚到上一份可用策略。

### Q2：策略 JSON 无法直接附加到 IAM？

**A**：先删除 `_hc_note` 说明字段并替换全部 `<...>` 占位符；再核对 `Version` 为 `5.0`、`Action` 为「服务名:资源类型:操作」三段式、条件键与运算符均在官方名单内（见 `00-policy-format.md`）。策略无法表达的控制请按各分类 README 的「服务侧替代」小节在服务端配置。

### Q3：多账号怎么分发？

**A**：组织服务（SCP）按组织单元分发，或每个项目各创建 IAM 自定义策略。

### 故障排查清单

| 现象 | 可能原因 | 排查方法 |
|---|---|---|
| 策略无法解析 | 含未知条件键/动作名 | 对照 `00-policy-format.md` 与目标服务文档 |
| 未生效 | 作用对象/层级错误 | 确认绑定到正确的组织单元/项目 |
| 误伤合法操作 | 条件过宽 | 收窄 Action / 增加例外条件，先小范围验证 |

---

## 14. 贡献指南

欢迎提交 Issue 与 PR。请遵循以下流程：

1. **Issue**：描述问题 / 建议（含复现命令、预期 / 实际输出、截图）
2. **PR**：基于 `main` 分支新建 feature 分支；提交前校验 JSON 语法
3. **Code Review**：由 **[@<github-username>](https://github.com/<github-username>)** reviewer 审核通过后合并

详细规范参见 `CONTRIBUTING.md`（如有）。

---

## 15. 许可证

本实践采用 **MIT No Attribution** 许可证发布。详见仓库根目录 [`LICENSE`](LICENSE) 文件。

```
MIT No Attribution

Copyright (c) Huawei Cloud

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software... (no attribution required)
```

---

## 16. 联系方式 / 维护者

| 项 | 内容 |
|---|---|
| **创建者** | [@<github-username>](https://github.com/<github-username>) |
| **维护者** | [@<github-username>](https://github.com/<github-username>) |
| **联系方式** | GitHub Issues / PR（见 [第 14 节](#14-贡献指南)） |

---