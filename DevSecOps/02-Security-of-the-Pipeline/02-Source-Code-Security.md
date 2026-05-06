# Source Code Security

> **Room:** [https://tryhackme.com/room/sourcecodesecurity](https://tryhackme.com/room/sourcecodesecurity)
> **Module:** 2 — Security of the Pipeline
> **Difficulty:** Medium

## Overview

This room is about protecting the source code itself — repository security, branch protection, secrets management, and what happens when code or credentials leak. You'll see how attackers find secrets in Git history and how to prevent it.

---

## Key Concepts

### Why source code matters

Source code is the crown jewel — leak it and attackers learn:
- Your business logic
- Hidden API endpoints
- Hardcoded credentials
- Vulnerable dependencies you use
- Internal infrastructure layout

### Common source code security risks

1. **Hardcoded secrets** — API keys, passwords, tokens committed to repos
2. **Sensitive files** — `.env`, `id_rsa`, `config.yml` accidentally pushed
3. **Source code leaks** — full repos accidentally made public
4. **Insider threats** — disgruntled employees stealing code
5. **Compromised developer accounts** — attacker pushes malicious commits
6. **Vulnerable dependencies** in `package.json`, `requirements.txt`, etc.

### Repository security best practices

#### Access control
- Principle of **least privilege** — only give devs access to repos they need
- Use **groups/teams** for managing permissions
- Enable **MFA** for all developer accounts
- Rotate access tokens regularly

#### Branch protection
- Protect `main` / `master` / `production` branches
- Require pull request reviews before merging (typically 1–2 reviewers)
- Require **status checks** to pass (CI tests, security scans)
- Require **signed commits** to prove identity
- Disallow force-pushes to protected branches
- Disallow direct pushes — everything goes through PR

#### Code review
- Every PR reviewed by at least one other person
- Use a security checklist for reviewers
- Automated review tools (CodeQL, Snyk) augment human review

### Secrets management

**Don't commit secrets to source control. Ever.**

But people do, all the time. So:

#### Detect secrets
- **`git-secrets`** — pre-commit hook that blocks commits with secrets patterns
- **`trufflehog`** — scans repos (and Git history) for secrets
- **`gitleaks`** — similar, finds secrets in code and history
- **GitHub secret scanning** — built-in, alerts on known token formats

#### Store secrets properly
- **HashiCorp Vault** — popular open-source secrets manager
- **AWS Secrets Manager / Parameter Store**
- **Azure Key Vault**
- **GCP Secret Manager**
- **Kubernetes Secrets** (with proper encryption at rest)

#### Use environment variables
```bash
# Bad
api_key = "sk_live_abc123..."

# Good
api_key = os.environ.get("API_KEY")
```

### Git history is forever

Even if you delete a secret in a new commit, **the secret is still in the Git history**. You have to:
1. Remove it from history (`git filter-repo` or `git filter-branch` or BFG Repo-Cleaner)
2. Force-push the rewritten history
3. **Rotate the secret immediately** — assume it's compromised the moment it was committed

### Common Git mistakes

- Committing `.env` files (use `.gitignore`!)
- Committing private SSH keys
- Pushing internal repos to a public account by accident
- Leaving repos public after testing
- Storing backups (`.bak`, `.old`) inside the repo

### `.gitignore` essentials

```
# Secrets
.env
.env.*
*.pem
*.key
id_rsa
id_rsa.pub

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Build artifacts
node_modules/
dist/
build/
__pycache__/
*.pyc

# Logs
*.log
```

### Real-world incidents

- **Uber (2016)** — engineer's GitHub account was compromised. Attackers found AWS credentials in the repo and stole 57 million users' data.
- **Mercedes-Benz (2024)** — internal source code was exposed when a GitHub token was accidentally committed to a public repo.
- **Toyota** — multiple leaks of customer data caused by repos accidentally being made public.

---

## Commands Cheatsheet

### Searching Git history for secrets

```bash
# Search current code for "password"
grep -r "password" .

# Search ALL commits in history for a string
git log -p -S "password"

# Search history for specific patterns
git log --all --oneline -S "API_KEY"

# View what changed in a commit
git show <commit-hash>

# List files ever added to the repo
git log --all --pretty=format: --name-only --diff-filter=A | sort -u
```

### Using trufflehog

```bash
# Install
pip install trufflehog
# or via Docker
docker run -it --rm trufflesecurity/trufflehog

# Scan a Git repo
trufflehog git https://github.com/<user>/<repo>

# Scan a local directory
trufflehog filesystem ./my-project

# Scan with verified results only (less noise)
trufflehog git https://github.com/<user>/<repo> --only-verified
```

### Using gitleaks

```bash
# Install (macOS)
brew install gitleaks

# Scan repo for secrets
gitleaks detect --source . -v

# Scan and produce a report
gitleaks detect --source . --report-path leaks-report.json
```

### Using git-secrets

```bash
# Install
brew install git-secrets

# Configure it on a repo
git secrets --install
git secrets --register-aws        # adds AWS patterns

# Scan repo
git secrets --scan
git secrets --scan-history
```

### Removing a secret from Git history

```bash
# Using BFG (much faster than filter-branch)
bfg --replace-text passwords.txt
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force

# Using git filter-repo (modern alternative)
git filter-repo --path secrets.txt --invert-paths
```

### Branch protection (via GitHub CLI)

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_pull_request_reviews[required_approving_review_count]=2 \
  --field enforce_admins=true
```

### Git commit signing

```bash
# Generate a GPG key
gpg --full-generate-key

# List keys
gpg --list-secret-keys --keyid-format=long

# Tell git to use it
git config --global user.signingkey <KEY-ID>
git config --global commit.gpgsign true

# Sign a commit
git commit -S -m "signed commit"
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — Repository Security**
- Q: What's the principle that says give users only the access they need?
- A: `least privilege` (or `principle of least privilege`)
- Q: What feature stops force-pushes to main?
- A: `branch protection`

**Task 3 — Secrets in Source Code**
- Q: Name a tool used to find secrets in Git history.
- A: `trufflehog` (also accepts `gitleaks` or `git-secrets`)

**Task 4 — Practical / Find the secret**
- The room typically asks you to scan a provided repo for a flag/secret.
- Use: `trufflehog git <repo-url>` or `gitleaks detect --source .`
- Look in older commits — secrets are often "removed" but still in history.
- Use `git log -p -S "<keyword>"` to grep through commits.

**Task 5 — Conclusion**
- Click to complete.

> Specific flag values will be unique to your machine instance — find them by running the scanning commands above.

---

## Key Takeaways

1. Source code is high-value — leaks expose business logic, secrets, and infrastructure.
2. **Branch protection** + **mandatory PR reviews** + **MFA** = baseline repo security.
3. Never commit secrets. Use `.gitignore` and a real secrets manager (Vault, AWS Secrets Manager, etc.).
4. Once a secret is committed, treat it as compromised — rotate it, then clean history.
5. Scanning tools to know: **trufflehog, gitleaks, git-secrets**.
