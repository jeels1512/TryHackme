# Room 1 — Intro to Pipeline Automation
## Task 1: Conceptual Questions

Answer each question below. The flag for each task is revealed at the bottom — 
**try to answer first before scrolling down.**

---

### Q1. What does CI stand for in a CI/CD pipeline?

<details>
<summary>Hint</summary>
It refers to the practice of merging code changes frequently and running automated tests.
</details>

<details>
<summary>Answer + Flag</summary>

**Answer:** Continuous Integration

**Flag:** `THM{CI_means_Continuous_Integration}`
</details>

---

### Q2. What are the TWO meanings of "CD" in DevOps?

<details>
<summary>Hint</summary>
One stops before production (manual gate), the other goes all the way automatically.
</details>

<details>
<summary>Answer + Flag</summary>

**Answer 1:** Continuous Delivery — auto-deploys to staging, production is manual  
**Answer 2:** Continuous Deployment — fully automatic all the way to production

**Flag:** `THM{CD_Delivery_AND_Deployment}`
</details>

---

### Q3. Which pipeline component actually *executes* the build jobs?

| Component            | Role                                      |
|----------------------|-------------------------------------------|
| SCM (Git)            | Stores source code                        |
| Build Server         | Orchestrates jobs (Jenkins, GitLab CI)    |
| **Build Agent/Runner** | **Executes the actual pipeline jobs**   |
| Artifact Repository  | Stores build outputs                      |
| Deployment Target    | Where code is deployed                    |

<details>
<summary>Answer + Flag</summary>

**Answer:** Build Agent (also called Runner)

**Flag:** `THM{Runner_Executes_The_Jobs}`
</details>

---

### Q4. Which CI/CD tool is self-hosted, uses plugins, and is common in enterprise environments?

<details>
<summary>Hint</summary>
It's one of the oldest CI tools, runs on port 8080, and has a plugin ecosystem of 1800+ plugins.
</details>

<details>
<summary>Answer + Flag</summary>

**Answer:** Jenkins

**Flag:** `THM{Jenkins_Is_Self_Hosted}`
</details>

---

### Q5. In the SolarWinds 2020 attack, how did the attackers deliver their backdoor to 18,000 customers?

<details>
<summary>Hint</summary>
They didn't hack each customer individually — they found a much more efficient entry point upstream.
</details>

<details>
<summary>Answer + Flag</summary>

**Answer:** They compromised SolarWinds' **build pipeline** and injected a backdoor into the Orion software update. Every customer who installed the legitimate update got the backdoor.

This is a **supply chain attack** via pipeline compromise.

**Flag:** `THM{SolarWinds_Build_Pipeline_Poisoned}`
</details>

---

### Q6. Match each platform to its config file location:

| Platform        | Config File Location              |
|-----------------|-----------------------------------|
| GitHub Actions  | ?                                 |
| GitLab CI       | ?                                 |
| Jenkins         | ?                                 |

<details>
<summary>Answer + Flag</summary>

| Platform        | Config File Location                    |
|-----------------|-----------------------------------------|
| GitHub Actions  | `.github/workflows/*.yml`               |
| GitLab CI       | `.gitlab-ci.yml` (root of repo)         |
| Jenkins         | `Jenkinsfile` (root of repo)            |

**Flag:** `THM{Know_Your_Pipeline_Config_Files}`
</details>

---

### Q7. Why is a self-hosted runner on a shared network dangerous?

<details>
<summary>Answer + Flag</summary>

**Answer:** If an attacker compromises a build job running on a self-hosted runner, they gain code execution **inside your network**. From there, they can:
- Access internal services (databases, APIs) not exposed to the internet
- Steal secrets from the runner's environment
- Pivot to other machines on the network

**Flag:** `THM{Self_Hosted_Runner_Is_A_Pivot_Point}`
</details>

---

## Task 1 Complete!
Collect all 7 flags and move to Task 2 → [task2-jenkins-analysis.md](task2-jenkins-analysis.md)
