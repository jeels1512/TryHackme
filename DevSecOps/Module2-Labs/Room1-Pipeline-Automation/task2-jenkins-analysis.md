# Room 1 — Task 2: Jenkins Config Analysis

You've been given access to a company's Jenkins `config.xml` file (see `jenkins-job-config.xml`).  
Your job: **find all the security misconfigurations and extract the hidden flags**.

---

## Instructions

1. Open `jenkins-job-config.xml`
2. Read through it carefully
3. For each misconfiguration you find, there's a flag embedded
4. Answer the questions below

---

## Questions

### Q1. What hardcoded credential is embedded directly in the Jenkinsfile build step?

<details>
<summary>Hint</summary>
Look inside the `<command>` tag of the shell build step.
</details>

<details>
<summary>Answer + Flag</summary>

The build step runs:
```bash
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYSECRETKEY aws s3 sync ...
```

The AWS secret key is **hardcoded** — anyone with access to this config (or build logs) can steal it.

**Flag:** `THM{Hardcoded_AWS_Secret_In_Jenkinsfile}`
</details>

---

### Q2. What dangerous trigger is configured that allows ANY user to start a build?

<details>
<summary>Hint</summary>
Look at the `<triggers>` section and the `<authToken>` field.
</details>

<details>
<summary>Answer + Flag</summary>

The config has:
```xml
<authToken>build123</authToken>
```

This means **anyone** who knows the URL and token can trigger a build remotely:
```
http://jenkins:8080/job/deploy-prod/build?token=build123
```

A weak, predictable token on a production deploy job is critical.

**Flag:** `THM{Weak_Auth_Token_Exposes_Build_Trigger}`
</details>

---

### Q3. What's wrong with the SCM (Git) configuration in this Jenkinsfile?

<details>
<summary>Hint</summary>
Look at the `<credentialsId>` field and the branch being built.
</details>

<details>
<summary>Answer + Flag</summary>

```xml
<branches>
  <hudson.plugins.git.BranchSpec>
    <name>*/main</name>
  </hudson.plugins.git.BranchSpec>
</branches>
```

The pipeline builds directly from `*/main` — **no pull request review required**. Anyone who pushes to main triggers a production deploy without review. This enables **Direct PPE** (Poisoned Pipeline Execution).

**Flag:** `THM{Direct_Push_To_Main_Enables_PPE}`
</details>

---

### Q4. The build runs as which user — and why is that a problem?

<details>
<summary>Hint</summary>
Look at the `<assignedNode>` and the shell commands in the build step.
</details>

<details>
<summary>Answer + Flag</summary>

The build runs `sudo docker build` and `sudo kubectl apply` — meaning the **Jenkins runner has sudo access**.  
If an attacker gains RCE through the pipeline, they immediately have root.

Principle of least privilege is violated — the runner should only have permissions needed for the build, not sudo.

**Flag:** `THM{Jenkins_Runner_Running_As_Sudo_Is_Dangerous}`
</details>

---

### Q5. What is the final deployed environment — and why does building AND deploying in the same job matter?

<details>
<summary>Hint</summary>
Check the `kubectl apply` command target and think about credential separation.
</details>

<details>
<summary>Answer + Flag</summary>

The job deploys to `--namespace production`. Build and deploy happen **in the same job** with the same credentials.

Best practice: **separate build and deploy** with different credentials and approval gates. A compromised build step should not automatically have access to production.

**Flag:** `THM{Separate_Build_And_Deploy_Credentials}`
</details>

---

## Task 2 Complete!
Move to Task 3 → [task3-github-actions-analysis.md](task3-github-actions-analysis.md)
