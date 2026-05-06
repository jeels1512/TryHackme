# Room 2 — Task 2: Branch Protection & Secrets Management

No setup needed — answer from knowledge and the reference material.

---

## Section A: Branch Protection Concepts

### Q1. A developer force-pushes to `main` and overwrites a colleague's work. Which branch protection rule would have prevented this?

<details>
<summary>Answer + Flag</summary>

**"Disallow force pushes"** (also called "Require linear history" in some platforms).

This setting prevents `git push --force` to the protected branch. Once enabled, the only way to update `main` is via a normal push of commits that are ahead of the current tip.

**Flag:** `THM{Disallow_Force_Push_Protects_Main}`
</details>

---

### Q2. Your team wants to ensure no code reaches `main` without at least one other person reviewing it. Which two branch protection settings do you enable?

<details>
<summary>Answer + Flag</summary>

1. **"Require pull request reviews before merging"** — blocks direct pushes, all changes must go through a PR
2. **"Required number of approvals: 1"** — at least one reviewer must approve the PR before merge

Together these ensure:
- No solo pushes to main
- Peer review on every change
- Audit trail of who approved what

**Flag:** `THM{PR_Reviews_Required_Before_Merge}`
</details>

---

### Q3. Your CI tests keep getting skipped before merging. What branch protection rule enforces that CI must pass before a PR can merge?

<details>
<summary>Answer + Flag</summary>

**"Require status checks to pass before merging"** — you specify which CI checks (e.g. `ci/tests`, `security/scan`) must be green before merge is allowed.

This prevents:
- Merging broken code
- Bypassing security scans
- Shipping without tests running

**Flag:** `THM{Status_Checks_Must_Pass_Before_Merge}`
</details>

---

### Q4. A developer wants to prove that a commit was actually made by them (not by an attacker who compromised their GitHub account and pushed as them). What feature provides this proof?

<details>
<summary>Hint</summary>
This involves cryptographic keys linked to the developer's identity.
</details>

<details>
<summary>Answer + Flag</summary>

**Signed commits** — using GPG or SSH keys, each commit is cryptographically signed by the author's private key.

GitHub shows a "Verified" badge on signed commits. If an attacker pushes commits without the developer's private key, the commits appear as "Unverified."

```bash
# Set up commit signing
git config --global user.signingkey <YOUR-GPG-KEY-ID>
git config --global commit.gpgsign true

# Make a signed commit
git commit -S -m "your message"
```

**Flag:** `THM{Signed_Commits_Prove_Authorship}`
</details>

---

## Section B: Secrets Management

### Q5. Your app needs a database password at runtime. List the correct order from WORST to BEST practice:

- A) Store it in a `.env` file committed to the repo
- B) Hardcode it directly in `app.py`
- C) Set it as an OS environment variable on the server
- D) Store it in HashiCorp Vault, fetched at runtime with a short-lived token

<details>
<summary>Answer + Flag</summary>

**WORST → BEST:**
1. **B — Hardcoded in source code** — worst. In the repo forever, visible to everyone with read access.
2. **A — .env committed to repo** — slightly better than inline code, but still in git history.
3. **C — OS environment variable** — good. Not in code. But rotations require server restarts.
4. **D — HashiCorp Vault with short-lived tokens** — best. Centralized, audited, rotatable, no secret touches disk.

**Flag:** `THM{Vault_Is_Best_Secrets_Manager}`
</details>

---

### Q6. A secret was committed to a public GitHub repo 3 days ago and then removed yesterday. What TWO actions must you take immediately?

<details>
<summary>Answer + Flag</summary>

1. **Rotate the secret immediately** — assume it's already been scraped. GitHub repos are indexed by bots within minutes. Treat the old secret as fully compromised.

2. **Rewrite Git history** to remove the secret from all commits, then force-push:
   ```bash
   # Using BFG Repo-Cleaner (fastest)
   bfg --replace-text secrets-to-remove.txt
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   git push --force

   # Or using git filter-repo
   git filter-repo --path .env --invert-paths
   ```

   > Note: rewriting history breaks everyone's local clones — coordinate with the team.

**Flag:** `THM{Rotate_First_Then_Rewrite_History}`
</details>

---

### Q7. What file should every repository have to prevent accidentally committing secrets and IDE files?

<details>
<summary>Answer + Flag</summary>

**`.gitignore`** — tells Git which files/patterns to never track.

Essential entries:
```
.env
.env.*
*.pem
*.key
id_rsa
*.p12
config/secrets.yml
node_modules/
.DS_Store
.idea/
.vscode/
```

**Pre-commit hook bonus:** combine with `git-secrets` or `gitleaks` as a pre-commit hook to actively block commits containing secrets.

**Flag:** `THM{Gitignore_Prevents_Secret_Commits}`
</details>

---

## Section C: Real-World Incident Analysis

### Q8. In the Uber 2016 breach, how did attackers access 57 million users' data?

<details>
<summary>Answer + Flag</summary>

Timeline:
1. Attacker found a **private GitHub repository** belonging to an Uber engineer
2. Inside, they found **hardcoded AWS credentials**
3. Used those credentials to access Uber's AWS S3 buckets
4. Downloaded database backups containing 57M user records and 600K driver records

The root cause: **AWS credentials committed to a private (but not secure enough) GitHub repo**.

Uber initially paid the attackers $100,000 to delete the data and stay quiet — later this itself became a legal issue.

**Flag:** `THM{Uber_AWS_Creds_In_GitHub_57M_Users}`
</details>

---

## Room 2 Complete!
Move to → [../Room3-CICD-Build-Security/](../Room3-CICD-Build-Security/)
