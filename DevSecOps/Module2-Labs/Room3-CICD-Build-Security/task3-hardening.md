# Room 3 — Task 3: CI/CD Hardening Deep Dive

---

## The 10-Point CI/CD Hardening Checklist

Work through each item below. For each one, answer the question to get the flag.

---

### 1. Least Privilege for Pipeline Credentials

**Concept:** The pipeline runner should only have the permissions it actually needs — no more.

**Bad:**
```yaml
# Runner has admin access to everything
permissions:
  contents: write-all
  actions: write
  packages: write
  deployments: write
  id-token: write
```

**Good:**
```yaml
# Only what this specific job needs
permissions:
  contents: read       # read code
  packages: write      # push Docker image only
```

**Q: A build job needs to read code and push a Docker image. What are the minimum two permissions it needs?**

<details>
<summary>Answer + Flag</summary>

- `contents: read` — to checkout the code
- `packages: write` — to push to GitHub Container Registry

Everything else should be omitted (defaults to `none`).

**Flag:** `THM{Least_Privilege_Contents_Read_Packages_Write}`
</details>

---

### 2. Ephemeral Runners

**Concept:** Runners should be destroyed after each job and recreated fresh.

**Why it matters:**
- A persistent runner accumulates state (credentials cached, known_hosts, artifacts)
- If one job compromises the runner, every future job on that runner is compromised
- Ephemeral runners get a clean environment every time

**GitHub Actions:** Hosted runners (ubuntu-latest, etc.) are **already ephemeral** — a fresh VM is created per job.

**Jenkins:** Self-hosted runners are often persistent. Solution: use Docker agents or cloud VMs that spin up and terminate per job.

```groovy
// Jenkins: ephemeral Docker agent
pipeline {
    agent {
        docker {
            image 'python:3.11-slim'
            args '--rm'    // container removed after job
        }
    }
}
```

**Q: Why does using a persistent self-hosted runner increase the blast radius of a PPE attack?**

<details>
<summary>Answer + Flag</summary>

A persistent runner may have:
- Cached credentials from previous jobs
- Files left by previous builds
- SSH known_hosts entries useful for pivoting
- Long-lived tokens that haven't been rotated

A PPE attack on one job can harvest **all of these** and use them to attack subsequent jobs or other systems. An ephemeral runner is clean — it has only the secrets explicitly injected for that job.

**Flag:** `THM{Ephemeral_Runners_Limit_PPE_Blast_Radius}`
</details>

---

### 3. Secret Masking

**Concept:** Build systems should automatically redact secret values from logs.

**GitHub Actions:** Secrets accessed via `${{ secrets.X }}` are auto-masked as `***`.

**Jenkins:** Use `withCredentials()` block:
```groovy
withCredentials([string(credentialsId: 'my-secret', variable: 'MY_SECRET')]) {
    sh 'curl -H "Auth: $MY_SECRET" https://api.example.com'
    // Logs show: curl -H "Auth: ****" https://api.example.com
}
```

**Bypass caveat:** Masking can be bypassed by encoding the secret:
```bash
echo $SECRET | base64      # base64 of the secret is NOT masked
echo $SECRET | rev         # reversed secret is NOT masked
```

This is why the primary defense is **never committing secrets** — masking is a secondary safeguard.

**Q: You run `echo $API_KEY | base64` in your build step. Will GitHub Actions mask the output?**

<details>
<summary>Answer + Flag</summary>

**No.** GitHub Actions only masks the exact literal value of the secret. A base64-encoded (or otherwise transformed) version of the secret will appear in plain text in the logs.

This is why masking is a last-resort safeguard — the real control is **not putting secrets in commands that produce visible output at all**.

**Flag:** `THM{Masking_Cant_Stop_Encoded_Secret_Leaks}`
</details>

---

### 4. Pinning Third-Party Actions to SHA

```yaml
# Vulnerable: tag can be changed by maintainer or attacker
- uses: actions/checkout@v4

# Safe: SHA is immutable
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
```

**How to find the SHA:**
```bash
# Check releases on GitHub and copy the full commit SHA
# Or use a tool like: https://app.stepsecurity.io/secureworkflow
```

**Q: A malicious actor compromises the npm account of the maintainer of a popular GitHub Action. They push a new version under the existing `@v2` tag. Your workflow uses `@v2`. What happens on your next build?**

<details>
<summary>Answer + Flag</summary>

Your workflow runs the **attacker's malicious code** — because `@v2` is a mutable tag that now points to the attacker's commit.

The attacker's action runs with the same permissions as a legitimate action, meaning it can:
- Read all environment variables (including `secrets.*`)
- Exfiltrate them to an attacker-controlled server
- Modify files, push code, create PRs

**If pinned to a SHA**, this attack fails — your workflow still runs the old, legitimate commit.

**Flag:** `THM{SHA_Pinning_Blocks_Compromised_Action_Maintainer}`
</details>

---

### 5. Artifact Signing with Cosign

**Concept:** After building a container image, sign it so the deploy step can verify it wasn't tampered with.

```bash
# Build
docker build -t myapp:v1.0.0 .
docker push registry.example.com/myapp:v1.0.0

# Sign (uses keyless signing via OIDC in CI)
cosign sign registry.example.com/myapp:v1.0.0

# Before deploy — verify
cosign verify \
  --certificate-identity-regexp="https://github.com/myorg/myrepo" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  registry.example.com/myapp:v1.0.0
```

**Q: What is an SBOM and why should you generate one per build?**

<details>
<summary>Answer + Flag</summary>

**SBOM = Software Bill of Materials** — a complete list of every component, library, and dependency in your built artifact.

Why it matters:
- When a new CVE drops (e.g. Log4Shell), you can instantly check which builds/products are affected
- Required by US Executive Order 14028 (cybersecurity) for software sold to the government
- Enables rapid incident response

Generate with Syft:
```bash
syft dir:./my-app -o spdx-json > sbom.json
syft my-image:latest -o cyclonedx-json > sbom-container.json
```

**Flag:** `THM{SBOM_Enables_Rapid_Vuln_Response}`
</details>

---

### 6. Separating Build and Deploy

**Bad:** Same pipeline job that builds also deploys. Same credentials.

**Good:**
```yaml
jobs:
  build:
    permissions:
      contents: read
      packages: write    # push to registry only
    steps:
      - build and push image

  deploy:
    needs: build         # depends on build succeeding
    environment: production   # requires manual approval gate
    permissions:
      id-token: write    # OIDC for cloud credentials only
    steps:
      - verify artifact signature
      - deploy to production
```

**Q: Why should the deploy job have a manual approval gate for production?**

<details>
<summary>Answer + Flag</summary>

A manual approval gate means a human must explicitly approve the deployment after seeing:
- What is being deployed (diff, changelog)
- That all checks passed
- That it's the right time (no on-call incidents, no deployment freeze)

Without an approval gate, a PPE attack that passes CI tests can deploy malicious code to production fully automatically.

In GitHub Actions, use **environments** with required reviewers:
```yaml
environment:
  name: production
  # Requires approval from a protected reviewer before this job runs
```

**Flag:** `THM{Manual_Approval_Gate_Stops_Auto_PPE_Deploy}`
</details>

---

## Final Challenge — Spot All Issues in This Pipeline

Read `final-challenge-pipeline.yml` and list every security issue.

```bash
cat final-challenge-pipeline.yml
```

<details>
<summary>Full Answer (8 issues)</summary>

1. **`pull_request_target` + untrusted checkout** → PPE via public PR
2. **`permissions: write-all`** → overly permissive token
3. **`actions/checkout@v3`** → floating tag, not SHA-pinned
4. **`npm install` instead of `npm ci`** → package-lock.json bypassed, untrusted versions
5. **`--ignore-scripts` missing** → lifecycle scripts in packages run (I-PPE via npm)
6. **`echo "Key: ${{ secrets.API_KEY }}"` → secret in log
7. **`run: ./deploy.sh ${{ github.event.pull_request.title }}`** → script injection
8. **No artifact integrity check before deploy**

**Flag:** `THM{8_Issues_Found_Pipeline_Fully_Hardened}`
</details>

---

## Room 3 Complete!

You've completed all of Module 2. Here's your full flag list:
</details>

Move to → [../MODULE2-FLAGS.md](../MODULE2-FLAGS.md)
