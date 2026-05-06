# Introduction to DevSecOps

> **Room:** [https://tryhackme.com/room/introductiontodevsecops](https://tryhackme.com/room/introductiontodevsecops)
> **Module:** 1 — Secure Software Development
> **Difficulty:** Easy

## Overview

This is the foundation room. It explains what DevSecOps is, why it exists, how it grew out of DevOps, and what "shift-left" means. By the end you understand why security has to be part of development from day one rather than tacked on at the end.

---

## Key Concepts

### What is DevSecOps?

DevSecOps stands for **Development, Security, and Operations**. It's a way of building software where security is part of every stage of development — not a final check before release.

Three pillars:
- **Development** — writing the code
- **Security** — making sure the code (and the infrastructure it runs on) is safe
- **Operations** — deploying, monitoring, and maintaining the running app

The idea: everyone in the team is responsible for security. Not just the security team.

### How we got here — quick history

1. **Waterfall** — old-school, linear development. Plan → design → build → test → release. Security came at the very end (or never). Slow, rigid, and bad at catching issues early.
2. **Agile** — short iterative sprints. Fast and flexible, but security was often skipped because "we'll fix it next sprint."
3. **DevOps** — broke down the wall between developers and operations. Pipelines, automation, fast deployment. But still no real focus on security.
4. **DevSecOps** — adds security as a first-class citizen alongside dev and ops.

### Shift-Left

"Shift-left" = move security checks earlier in the development lifecycle.

The further left (earlier) you catch a bug, the cheaper it is to fix:
- **Catch a bug while writing code** → minutes to fix
- **Catch it in testing** → hours
- **Catch it in production** → days, sometimes weeks, plus reputational damage

Shift-left tools: linters in your IDE, pre-commit hooks, SAST scanners in CI, dependency checkers.

### Benefits of DevSecOps

- Bugs caught earlier, cheaper to fix
- Faster, safer releases
- Security becomes everyone's job, not a bottleneck
- Compliance (PCI-DSS, GDPR, SOC2, etc.) is easier to maintain
- Better collaboration across teams

### Common DevSecOps practices

- **Threat modelling** during design
- **Secure coding standards** (OWASP Top 10 awareness)
- **Static Application Security Testing (SAST)** in CI
- **Dynamic Application Security Testing (DAST)** against running apps
- **Software Composition Analysis (SCA)** to scan dependencies
- **Infrastructure as Code (IaC) scanning** for misconfigured cloud resources
- **Secrets management** — never commit API keys to git
- **Continuous monitoring** in production

---

## Commands Cheatsheet

This is mostly a theory room — no terminal commands. The next rooms get hands-on.

---

## Room Answers

**Task 1 — Introduction**
- *No answer needed* — read through.

**Task 2 — What is DevSecOps?**
- Q: What does the acronym "DevSecOps" stand for?
- A: `Development, Security, and Operations`

**Task 3 — Code Analysis**
- Q: Where in the development lifecycle should security checks happen?
- A: `every stage` (or similar — the answer is that security is integrated throughout)

**Task 4 — Conclusion**
- Q: I have completed the Introduction to DevSecOps room!
- A: Click to complete.

> Note: TryHackMe occasionally tweaks question wording. If your room shows slightly different questions, the concept answers above still apply.

---

## Key Takeaways

1. DevSecOps = security woven into every stage of development.
2. Shift-left: catch bugs early, save time and money.
3. Security is everyone's responsibility — devs, ops, and security folks together.
4. The history: Waterfall → Agile → DevOps → DevSecOps.
5. The cheapest bug to fix is the one caught before it's even committed.
