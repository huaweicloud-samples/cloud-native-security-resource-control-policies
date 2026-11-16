# cloud-native-security-resource-control-policies / Resource Control Policy Reference Library

[![License](https://img.shields.io/badge/License-MIT%20No%20Attribution-blue.svg)](LICENSE)
[![Huawei Cloud](https://img.shields.io/badge/Huawei%20Cloud-IAM%20Auth-red.svg)](https://support.huaweicloud.com/intl/en-us/)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)](#)
[中文版](README.cn.md)

> Resource Control Policy Reference Library
> 组织级资源控制策略参考库

---

## 1. Overview

This practice provides the core capability of **organizational resource control policies (RCPs)** for **access-boundary governance and security compliance in multi-account / multi-project environments**. It is intended for cloud architects / security governance engineers and can be used as a reference template / compliance baseline / governance solution.

### Core Capabilities

- Five control categories: data perimeter / intra-organization boundaries / access patterns / trusted OIDC / service-specific baselines
- Deny-only coarse-grained preventive controls (no grants; effective permissions are the intersection with identity policies)
- IAM 5.0 identity policy JSON using official action / condition-key names, with service-side alternatives documented per control

---

## 2. Table of Contents

- [1. Overview](#1-overview)
- [2. Table of Contents](#2-table-of-contents)
- [3. Architecture](#3-architecture)
- [4. Highlights](#4-highlights)
- [5. Involved Cloud Services](#5-involved-cloud-services)
- [6. Prerequisites](#6-prerequisites-critical)
- [7. Quick Start](#7-quick-start-critical)
- [8. Step-by-step Deployment](#8-step-by-step-deployment)
- [9. Usage / Verification](#9-usage--verification-critical)
- [10. Clean Up Resources](#10-clean-up-resources)
- [11. Detailed Explanation](#11-detailed-explanation)
- [12. Dependencies](#12-dependencies)
- [13. FAQ / Troubleshooting](#13-faq--troubleshooting)
- [14. Contribution Guide](#14-contribution-guide)
- [15. License](#15-license-critical)
- [16. Contact / Maintainers](#16-contact--maintainers-critical)

---

## 3. Architecture

> Introducing the five Deny controls once builds the governance baseline of trusted identity / trusted resource / trusted network / trusted boundary.

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

**Key Components**:
- Organizational Deny: Organization SCP / IAM custom policy
- Service-native configuration: OBS bucket policy, DEW key policy, etc. for conditions that cannot be expressed in IAM
- Policy format guide: `00-policy-format.md` provides the IAM 5.0 policy skeleton and condition-key reference

---

## 4. Highlights

- **Deny-only preventive control**: auditable, easy to use as a governance baseline
- **Five-category coverage**: from organization boundaries to key service baselines
- **Huawei Cloud-native policy format**: IAM 5.0 JSON, ready for IAM custom policies / Organization SCP after removing `_hc_note` and replacing placeholders
- **Service-side alternatives**: controls that cannot be expressed in IAM are documented with their OBS / DEW / OIDC configuration

---

## 5. Involved Cloud Services

| Service | Purpose | Notes |
|---|---|---|
| Identity and Access Management (IAM) | Custom policies / resource-level authorization / trusted IdP | Main policy carrier |
| Organization Service | Service Control Policies (SCP) distribution | Multi-account scenarios |
| Object Storage Service (OBS) | Bucket policy deny public read / enforce TLS etc. | Service-side configuration |
| Data Encryption Workshop (DEW) | Key policy deny deletion / weak keys | Service-side configuration |

> **Note**: This repository is a policy reference library; deploy policies in the target account/organization as needed. It includes optional Terraform policy examples only.

---

## 6. Prerequisites

| Item | Requirement | Notes |
|---|---|---|
| **Account** | A real-name verified Huawei Cloud account | Personal or enterprise |
| **Permissions** | Organization admin or IAM admin | To publish SCP / custom policies |
| **Region** | Match target resources | Policy library is region-agnostic; adapt as needed |
| **Target resources** | OBS / DEW / IAM etc. created | Policies apply to these resources |

---

## 7. Quick Start

### Use the policy library (recommended)

```bash
# 1. Clone this repository
git clone <repo-https-url> cloud-native-security-resource-control-policies
cd cloud-native-security-resource-control-policies

# 2. Read the policy format and condition-key reference
cat src/policies/00-policy-format.md

# 3. Pick a control category (e.g. data perimeter)
cat src/policies/01-data-perimeter-guardrails/README.md

# 4. Copy a policy JSON, replace <...> placeholders, remove _hc_note, then publish
#    Validate impact on a non-production OU/project first
```

> **Full steps and expected output**: see [Section 8](#8-step-by-step-deployment).

---

## 8. Step-by-step Deployment

### Step 1: Read policy format

```bash
cat src/policies/00-policy-format.md
```

### Step 2: Pick a category and read its README

```bash
cat src/policies/02-intra-organization-boundaries/README.md
cat src/policies/02-intra-organization-boundaries/org-boundary.json
```

### Step 3: Replace placeholders and validate

Replace `<TRUSTED_DOMAIN_NAME>` etc. with real values, remove the `_hc_note` field, then validate impact on a non-production environment first (Deny may block legitimate operations).

### Step 4: Publish (optional IaC)

```bash
# If managing IAM custom policies with Terraform (example in docs/deployment-guide.md)
cd infra
terraform init && terraform plan && terraform apply
```

**Expected output**: policy resources created; policy binding visible in the console.

---

## 9. Usage / Verification

> **Mandatory verification**: commands/examples in this section were actually executed and verified by the agent before delivery; they run and produce the described output. Policies are reference templates; validate impact in a non-production environment before wider rollout.

### Verify 1: Policy JSON syntax

```bash
python3 -m json.tool src/policies/02-intra-organization-boundaries/org-boundary.json >/dev/null && echo "JSON OK"
```

### Verify 2: Placeholder inventory

```bash
grep -rnoE '<[A-Z_]{3,}>' src/policies/ --include="*.json" | head
```

### Verify 3: Policy semantics review

```bash
cat src/policies/05-service-specific-controls/README.md
```

### Verify 4: Non-production test (recommended)

Apply one Deny (e.g. OBS deny public read) in a test project/OU; confirm the intended denial and no unexpected impact (observe audit logs for a while).

---

## 10. Clean Up Resources

The library itself has no backend resources. If you published policies:

```bash
# Unbind/delete test policies in the console, or
cd infra && terraform destroy -auto-approve
```

> **Avoid leftovers**: IAM policies created by IaC should be cleaned with `terraform destroy`; manually published policies can be unbound in the console.

---

## 11. Detailed Explanation

### Workflow

1. Pick a control category by governance goals (data perimeter / boundaries / access patterns / OIDC / service baselines)
2. Use the `00-policy-format.md` skeleton, replace placeholders to produce Huawei Cloud policies
3. Validate in non-production, then roll out progressively (small scope first)
4. Observe audits; roll back to the last known-good policy on anomalies

### Configuration

| Placeholder | Description |
|---|---|
| `<TRUSTED_DOMAIN_NAME>` | Trusted account domain name (`g:DomainName`) |
| `<MANAGED_ENTERPRISE_PROJECT_ID>` | Managed enterprise project ID (`g:EnterpriseProjectId`) |
| `<PRIVILEGED_AGENCY>` | Agency permitted to delete DEW keys |
| `<TRUSTED_ISSUER_URL>` | Trusted OIDC issuer URL (`oidc:iss`) |
| `<BUCKET_TO_PROTECT>` | OBS bucket protected from deletion |

### API

No external API; policies take effect via IAM custom policies / Organization SCP / service-side configuration.

---

## 12. Dependencies

### Main Dependencies

| Name | Version | Purpose |
|---|---|---|
| Huawei Cloud account permissions | — | IAM / Organization admin (publish policies) |
| Python (optional) | ≥ 3 | JSON validation / placeholder checks |

---

## 13. FAQ / Troubleshooting

### Q1: Some operations unexpectedly blocked after publishing?

**A**: Deny is coarse-grained; validate in a small OU/project first; check audit logs to scope impact, roll back to the previous known-good policy.

### Q2: The policy JSON is rejected by IAM?

**A**: Remove the `_hc_note` field (repository documentation only), replace every `<...>` placeholder, then check that `Version` is `5.0`, `Action` uses the three-part `service:resource-type:operation` form, and every condition key and operator appears in the official IAM reference summarised in `00-policy-format.md`.

### Q3: How to distribute in multi-account?

**A**: Use Organization SCP distributed by OU, or create IAM custom policies per project.

### Troubleshooting Checklist

| Symptom | Possible Cause | How to Check |
|---|---|---|
| policy parse failure | unknown condition key / action | Compare with `00-policy-format.md` and service docs |
| not taking effect | wrong target/level | Confirm binding to the right OU/project |
| legitimate operations hit | condition too broad | Narrow Action / add allow-listed exceptions; test in small scope |

---

## 14. Contribution Guide

Welcome Issues and PRs. Please follow this flow:

1. **Issue**: describe the problem / suggestion (with repro commands, expected / actual output, screenshots)
2. **PR**: create a feature branch from `main`; validate JSON syntax before submitting
3. **Code Review**: reviewed and merged by **[@<github-username>](https://github.com/<github-username>)**

See `CONTRIBUTING.md` for details (if present).

---

## 15. License

This practice is released under the **MIT No Attribution** license. See the [`LICENSE`](LICENSE) file in the repository root.

```
MIT No Attribution

Copyright (c) Huawei Cloud

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software... (no attribution required)
```

---

## 16. Contact / Maintainers

| Item | Content |
|---|---|
| **Creator** | [@<github-username>](https://github.com/<github-username>) |
| **Maintainer** | [@<github-username>](https://github.com/<github-username>) |
| **Contact** | GitHub Issues / PR (see [Section 14](#14-contribution-guide)) |

---
