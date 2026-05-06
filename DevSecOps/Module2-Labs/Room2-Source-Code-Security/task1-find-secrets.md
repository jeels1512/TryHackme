# Room 2 — Task 1: Find Secrets in Git History

## Setup (do this first!)

```bash
cd /home/user/TryHackme/DevSecOps/Module2-Labs/Room2-Source-Code-Security
bash setup-lab.sh
cd acmecorp-webapp
```

You now have a Git repository that looks clean on the surface.  
A developer committed secrets at various points and then "removed" them.  
**Your job: find all 4 hidden flags.**

---

## Background: Why Git History Is Dangerous

When a developer commits a secret and then deletes it in a later commit, the secret is NOT gone.  
Git stores every version of every file. The "deletion" commit just removes it from HEAD —  
the secret lives forever in the commit history unless history is **rewritten**.

---

## Challenge 1 — Find the leaked .env file

The current repo has no `.env` file. But one was committed earlier...

### Your tools:

```bash
# List all commits (start here)
git log --oneline

# Search all commits for a specific string
git log --all --oneline -S "STRIPE"

# View what a specific commit added/removed
git show <commit-hash>

# Search through all commit diffs for a pattern
git log -p --all | grep -A5 "STRIPE"
```

### Question: What is the Stripe secret key that was committed in the .env file?

<details>
<summary>Hint</summary>
Search git history for "STRIPE_SECRET_KEY". The .env file was added then removed. Look for the commit that added it.
</details>

<details>
<summary>Step-by-step solution</summary>

```bash
# Find which commit touched the .env file
git log --all --oneline -- .env

# View the commit that ADDED .env (the earlier one)
git show <commit-hash-that-added-env>

# Or search by content
git log -p --all -S "STRIPE_SECRET_KEY"
```

You'll find:
```
STRIPE_SECRET_KEY=sk_live_51NxTHM_flag1_THM{D0t_Env_F1l3_L3aked_S3cr3ts}
```

**Flag 1:** `THM{D0t_Env_F1l3_L3aked_S3cr3ts}`
</details>

---

## Challenge 2 — Find the hardcoded AWS key in source code

A developer hardcoded AWS credentials in a Python file.  
The file still exists at HEAD — no removal this time.

### Your tools:

```bash
# Search current files for AWS patterns
grep -r "AWS" src/
grep -r "AKIA" src/        # AWS Access Key IDs always start with AKIA

# Search all history too
git log -p --all | grep -B2 "AKIA"
```

### Question: What is the AWS Access Key ID hardcoded in the storage module?

<details>
<summary>Hint</summary>
Look in src/storage.py — it was added in the "S3 storage integration" commit.
</details>

<details>
<summary>Step-by-step solution</summary>

```bash
cat src/storage.py
# or
grep -n "AWS_KEY\|AWS_SECRET\|THM" src/storage.py
```

You'll find in the comment:
```python
# FLAG: THM{H4rdC0d3d_AWS_K3y_1n_Src_C0d3}
```

**Flag 2:** `THM{H4rdC0d3d_AWS_K3y_1n_Src_C0d3}`
</details>

---

## Challenge 3 — Find the committed SSH private key

A private SSH key was committed and then removed. It's still in history.

### Your tools:

```bash
# Search history for private key header
git log -p --all | grep -A20 "BEGIN RSA PRIVATE KEY"

# Or search which commits touched the keys directory
git log --all --oneline -- deploy/keys/

# View the commit that added the key
git show <commit-hash>
```

### Question: What flag is embedded in the RSA private key file?

<details>
<summary>Step-by-step solution</summary>

```bash
# Find commits that touched deploy/keys/
git log --all --oneline -- deploy/keys/deploy_rsa

# Show the commit that ADDED the file (first one in the list)
git show <add-commit-hash>
```

You'll see the fake private key containing:
```
THM{SSH_Pr1v4t3_K3y_C0mm1tt3d_T0_R3p0}
```

**Flag 3:** `THM{SSH_Pr1v4t3_K3y_C0mm1tt3d_T0_R3p0}`
</details>

---

## Challenge 4 — Find the database password in a config file

A YAML config file was committed with a real production database password.  
This one is still present at HEAD.

### Your tools:

```bash
# Look at config files
ls config/
cat config/database.yml

# Or grep for password patterns
grep -r "password" config/
```

### Question: What is the production database password in the config file?

<details>
<summary>Step-by-step solution</summary>

```bash
cat config/database.yml | grep password
```

**Flag 4:** `THM{DB_P4ssw0rd_1n_C0nf1g_Y4ml}`
</details>

---

## Bonus Challenge — Use grep to find ALL secrets at once

Try this command to sweep for common secret patterns across the entire git history:

```bash
git log -p --all | grep -iE "(password|secret|api_key|token|private_key|aws_secret)" | head -30
```

---

## Key Lessons

1. Deleting a file in a new commit does NOT remove it from Git history
2. `git log -p -S "keyword"` is your most powerful tool for history forensics
3. `grep -r "AKIA" .` finds AWS keys in current files
4. Once committed, a secret must be **rotated immediately** — assume it's compromised

Move to → [task2-branch-protection.md](task2-branch-protection.md)
