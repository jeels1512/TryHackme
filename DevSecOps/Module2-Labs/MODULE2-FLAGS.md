# Module 2 — Complete Flag Sheet

Track your progress. Check off each flag as you find it.

---

## Room 1 — Intro to Pipeline Automation

| # | Task | Flag | Found? |
|---|------|-------|--------|
| 1 | CI stands for... | `THM{CI_means_Continuous_Integration}` | [ ] |
| 2 | CD meanings | `THM{CD_Delivery_AND_Deployment}` | [ ] |
| 3 | Component that executes jobs | `THM{Runner_Executes_The_Jobs}` | [ ] |
| 4 | Self-hosted CI tool | `THM{Jenkins_Is_Self_Hosted}` | [ ] |
| 5 | SolarWinds attack vector | `THM{SolarWinds_Build_Pipeline_Poisoned}` | [ ] |
| 6 | Pipeline config file locations | `THM{Know_Your_Pipeline_Config_Files}` | [ ] |
| 7 | Self-hosted runner risk | `THM{Self_Hosted_Runner_Is_A_Pivot_Point}` | [ ] |
| 8 | Jenkins: Hardcoded AWS key | `THM{Hardcoded_AWS_Secret_In_Jenkinsfile}` | [ ] |
| 9 | Jenkins: Weak auth token | `THM{Weak_Auth_Token_Exposes_Build_Trigger}` | [ ] |
| 10 | Jenkins: Direct push to main | `THM{Direct_Push_To_Main_Enables_PPE}` | [ ] |
| 11 | Jenkins: Runner sudo access | `THM{Jenkins_Runner_Running_As_Sudo_Is_Dangerous}` | [ ] |
| 12 | Jenkins: Build+deploy same job | `THM{Separate_Build_And_Deploy_Credentials}` | [ ] |
| 13 | GH Actions: pull_request_target | `THM{pull_request_target_Plus_Checkout_Is_Critical_RCE}` | [ ] |
| 14 | GH Actions: floating tags | `THM{Pin_Actions_To_SHA_Not_Tags}` | [ ] |
| 15 | GH Actions: secret in echo | `THM{Never_Echo_Secrets_In_Build_Logs}` | [ ] |
| 16 | GH Actions: write-all token | `THM{Least_Privilege_For_GITHUB_TOKEN}` | [ ] |
| 17 | GH Actions: script injection | `THM{Script_Injection_Via_PR_Title}` | [ ] |

**Room 1 Score: __ / 17**

---

## Room 2 — Source Code Security

### Practical (Git History)

| # | Task | Flag | Found? |
|---|------|-------|--------|
| 1 | Find leaked .env (Stripe key) | `THM{D0t_Env_F1l3_L3aked_S3cr3ts}` | [ ] |
| 2 | Hardcoded AWS key in src/storage.py | `THM{H4rdC0d3d_AWS_K3y_1n_Src_C0d3}` | [ ] |
| 3 | SSH private key in git history | `THM{SSH_Pr1v4t3_K3y_C0mm1tt3d_T0_R3p0}` | [ ] |
| 4 | DB password in config/database.yml | `THM{DB_P4ssw0rd_1n_C0nf1g_Y4ml}` | [ ] |

### Conceptual

| # | Task | Flag | Found? |
|---|------|-------|--------|
| 5 | Force push protection rule | `THM{Disallow_Force_Push_Protects_Main}` | [ ] |
| 6 | PR review requirement | `THM{PR_Reviews_Required_Before_Merge}` | [ ] |
| 7 | Status checks rule | `THM{Status_Checks_Must_Pass_Before_Merge}` | [ ] |
| 8 | Commit signing | `THM{Signed_Commits_Prove_Authorship}` | [ ] |
| 9 | Best secrets manager | `THM{Vault_Is_Best_Secrets_Manager}` | [ ] |
| 10 | Response to leaked secret | `THM{Rotate_First_Then_Rewrite_History}` | [ ] |
| 11 | .gitignore purpose | `THM{Gitignore_Prevents_Secret_Commits}` | [ ] |
| 12 | Uber 2016 breach | `THM{Uber_AWS_Creds_In_GitHub_57M_Users}` | [ ] |

**Room 2 Score: __ / 12**

---

## Room 3 — CI/CD and Build Security

### Conceptual (PPE)

| # | Task | Flag | Found? |
|---|------|-------|--------|
| 1 | I-PPE via Makefile | `THM{Indirect_PPE_Via_Makefile}` | [ ] |
| 2 | OWASP: dependency abuse | `THM{CICD_SEC_3_Dependency_Chain_Abuse}` | [ ] |
| 3 | GITHUB_TOKEN write-all impact | `THM{Stolen_GITHUB_TOKEN_With_Write_Is_Game_Over}` | [ ] |
| 4 | Dependency confusion | `THM{Dependency_Confusion_Alex_Birsan_2021}` | [ ] |

### Practical (Pipeline Lab)

| # | Task | Flag | Found? |
|---|------|-------|--------|
| 5 | Jenkins credentials.xml | `THM{J3nk1ns_Cr3d3nt14ls_XML_Exf1ltr4t3d}` | [ ] |
| 6 | I-PPE via Makefile simulation | `THM{1nd1r3ct_PPE_M4k3f1le_Exf1ltr4t10n}` | [ ] |
| 7 | Debug stage vulnerability | `THM{Debug_Stage_Leaks_Master_Key_And_Env}` | [ ] |
| 8 | Artifact tampering | `THM{Ver1fy_Art1f4ct_Sh4_B3for3_D3ploy}` | [ ] |
| 9 | SHA pinning vs tags | `THM{Pin_To_SHA_Prevents_Supply_Chain_Attack}` | [ ] |
| 10 | Secret masking bypass | `THM{Env_Var_Injection_Masks_Secrets_In_Logs}` | [ ] |

### Hardening Deep Dive

| # | Task | Flag | Found? |
|---|------|-------|--------|
| 11 | Minimum permissions | `THM{Least_Privilege_Contents_Read_Packages_Write}` | [ ] |
| 12 | Ephemeral runner benefit | `THM{Ephemeral_Runners_Limit_PPE_Blast_Radius}` | [ ] |
| 13 | Base64 masking bypass | `THM{Masking_Cant_Stop_Encoded_Secret_Leaks}` | [ ] |
| 14 | Compromised action maintainer | `THM{SHA_Pinning_Blocks_Compromised_Action_Maintainer}` | [ ] |
| 15 | SBOM value | `THM{SBOM_Enables_Rapid_Vuln_Response}` | [ ] |
| 16 | Manual approval gate | `THM{Manual_Approval_Gate_Stops_Auto_PPE_Deploy}` | [ ] |
| 17 | Final challenge (8 issues) | `THM{8_Issues_Found_Pipeline_Fully_Hardened}` | [ ] |

**Room 3 Score: __ / 17**

---

## Total Module 2 Score: __ / 46 flags

---

## Quick Reference — Commands You Used

```bash
# Git history forensics
git log --oneline
git log --all --oneline -S "keyword"
git log -p --all | grep -A5 "pattern"
git show <commit-hash>
git log --all --oneline -- <filename>

# Find secrets in current files
grep -r "AKIA" .
grep -r "password\|secret\|api_key" . --include="*.py" --include="*.yml"

# Artifact integrity
sha256sum <file>
cosign verify --key cosign.pub <image>

# Simulate I-PPE
make test    # after modifying Makefile
```
