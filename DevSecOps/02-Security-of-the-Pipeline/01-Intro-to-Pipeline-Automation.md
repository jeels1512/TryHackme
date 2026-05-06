# Intro to Pipeline Automation

> **Room:** [https://tryhackme.com/room/introtopipelineautomation](https://tryhackme.com/room/introtopipelineautomation)
> **Module:** 2 — Security of the Pipeline
> **Difficulty:** Medium

## Overview

This room introduces CI/CD pipelines — what they are, the tools that build them (Jenkins, GitHub Actions, GitLab CI), and why they're a juicy target for attackers. You'll learn the components of a pipeline and where security weaknesses appear.

---

## Key Concepts

### What is a CI/CD pipeline?

A pipeline automates the steps between writing code and deploying it.

- **CI — Continuous Integration:** every code change triggers automated build + tests. Catches integration issues early.
- **CD — Continuous Delivery:** automatically deploys to staging; production deployment is manual.
- **CD — Continuous Deployment:** fully automatic deploy to production after tests pass.

### Why automate?

- Speed — devs ship code multiple times a day
- Consistency — same steps every time, no human error
- Quality — automated tests catch bugs early
- Audit trail — every build is logged
- Lets devs focus on writing code, not deploying it

### Pipeline components

1. **Source Code Management (SCM)** — Git, GitHub, GitLab, Bitbucket
2. **Build server / orchestrator** — Jenkins, GitLab CI, GitHub Actions, CircleCI, Azure DevOps
3. **Build agent / runner** — actually executes the pipeline jobs
4. **Artifact repository** — where build outputs are stored (Nexus, Artifactory, Docker registries)
5. **Deployment target** — staging/production servers, Kubernetes clusters, cloud services

### Common pipeline stages

```
Commit → Build → Test → Security Scan → Package → Deploy → Monitor
```

### Popular CI/CD platforms

| Platform | Notes |
|----------|-------|
| **Jenkins** | Self-hosted, very extensible via plugins, oldest, common in enterprise |
| **GitHub Actions** | Built into GitHub, YAML workflows in `.github/workflows/` |
| **GitLab CI** | Built into GitLab, defined in `.gitlab-ci.yml` |
| **CircleCI** | SaaS, fast and cloud-native |
| **Azure DevOps** | Microsoft's offering, integrates with Azure |
| **Travis CI** | One of the original SaaS CI tools |

### Why pipelines are attractive targets

The pipeline has **enormous power** — it can deploy to production, holds secrets, and runs trusted code. If an attacker compromises it, they can:
- Inject malicious code into builds (supply chain attack)
- Steal secrets (API keys, cloud credentials, signing keys)
- Deploy backdoors directly to production
- Pivot to other systems on the network

### Common pipeline weaknesses

- **Hardcoded secrets** in pipeline files
- **Overly permissive credentials** (build runner has prod admin rights)
- **Untrusted third-party actions/plugins** (especially in GitHub Actions)
- **No code signing** — anyone who can modify the pipeline can ship anything
- **Public build logs** leaking sensitive info
- **Self-hosted runners on shared infrastructure**
- **No separation between build and deploy** — same job that builds also deploys

### Real-world examples

- **SolarWinds (2020)** — attackers compromised the build pipeline and inserted a backdoor into the Orion update, affecting ~18,000 customers including US government agencies.
- **Codecov (2021)** — attacker modified a CI script in the Codecov bash uploader, exfiltrating CI environment variables (including secrets) from thousands of customers.

---

## Commands Cheatsheet

### Jenkins (basic)

```bash
# Start Jenkins (if installed as a service)
sudo systemctl start jenkins
sudo systemctl status jenkins

# Default URL
http://<host>:8080

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Jenkins CLI - run a job
java -jar jenkins-cli.jar -s http://<host>:8080/ build <job-name> --username admin --password <pass>

# View build console output
java -jar jenkins-cli.jar -s http://<host>:8080/ console <job-name>
```

### GitHub Actions

Workflows live in `.github/workflows/*.yml`. Example:

```yaml
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: npm test
```

### GitLab CI

Defined in `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - test
  - deploy

build-job:
  stage: build
  script:
    - echo "Building..."
    - make build

test-job:
  stage: test
  script:
    - npm test

deploy-job:
  stage: deploy
  script:
    - ./deploy.sh
  only:
    - main
```

### Useful Git commands for pipelines

```bash
git log --oneline                  # see commit history
git show <commit>                  # see what a commit changed
git tag v1.0.0                     # tag a release
git push origin v1.0.0             # push tag (often triggers a release pipeline)
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — What is a Pipeline?**
- Q: What does CI stand for?
- A: `Continuous Integration`
- Q: What does CD stand for? (two answers)
- A: `Continuous Delivery` / `Continuous Deployment`

**Task 3 — Pipeline Components**
- Q: Which component stores the source code?
- A: `Source Code Management` (or `SCM`)
- Q: Which component executes pipeline jobs?
- A: `Build Agent` (or `Runner`)

**Task 4 — Pipeline Tools**
- Q: Which CI/CD tool is built into GitHub?
- A: `GitHub Actions`
- Q: Which CI/CD tool is known for being self-hosted and using plugins?
- A: `Jenkins`

**Task 5 — Why Pipelines Matter for Security**
- Q: Name a famous supply chain attack that exploited a build pipeline.
- A: `SolarWinds` (or `Codecov`)

**Task 6 — Practical**
- The room usually includes a hands-on portion where you log into Jenkins or a similar tool. Follow the on-screen instructions — flags appear in the Jenkins job output or console after triggering a build.

**Task 7 — Conclusion**
- Click to complete.

> Note: This room has a lab component that varies — answers from the lab are unique per task. The conceptual answers above are what shows up in the multiple-choice/fill-in-blank questions.

---

## Key Takeaways

1. Pipelines automate the path from code commit to production.
2. Main components: SCM → Build Server → Runner → Artifact Repo → Deployment.
3. Pipelines are high-value targets — they hold secrets and deploy code.
4. Major tools: **Jenkins, GitHub Actions, GitLab CI, CircleCI, Azure DevOps**.
5. Real attacks (SolarWinds, Codecov) prove pipeline security isn't theoretical — it's critical.
