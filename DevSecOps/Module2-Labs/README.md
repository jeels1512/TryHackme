# Module 2 Labs — Security of the Pipeline

Hands-on practical labs mirroring the TryHackMe DevSecOps Module 2 rooms.  
Each room has conceptual Q&A tasks and hands-on practical challenges with real flags.

---

## Start Here

```
Module2-Labs/
├── Room1-Pipeline-Automation/
│   ├── task1-concepts.md              ← 7 conceptual Q&A flags
│   ├── task2-jenkins-analysis.md      ← 5 flags (analyse jenkins-job-config.xml)
│   ├── jenkins-job-config.xml         ← vulnerable Jenkins config to analyse
│   ├── task3-github-actions-analysis.md  ← 5 flags (analyse vulnerable-workflow.yml)
│   └── vulnerable-workflow.yml        ← vulnerable GitHub Actions workflow
│
├── Room2-Source-Code-Security/
│   ├── setup-lab.sh                   ← RUN THIS FIRST
│   ├── task1-find-secrets.md          ← 4 flags (hunt Git history)
│   └── task2-branch-protection.md     ← 8 flags (concepts + incidents)
│
├── Room3-CICD-Build-Security/
│   ├── setup-pipeline-lab.sh          ← RUN THIS FIRST
│   ├── task1-ppe-concepts.md          ← 4 flags (PPE theory deep dive)
│   ├── task2-ppe-simulation.md        ← 6 flags (hands-on exploitation)
│   ├── task3-hardening.md             ← 7 flags (hardening checklist)
│   └── final-challenge-pipeline.yml   ← find all 8 issues
│
└── MODULE2-FLAGS.md                   ← master flag tracker (46 total)
```

---

## Setup Instructions

### Room 2 (Git History Lab)
```bash
cd Room2-Source-Code-Security
bash setup-lab.sh
cd acmecorp-webapp
# Then open task1-find-secrets.md and start hunting
```

### Room 3 (Pipeline Security Lab)
```bash
cd Room3-CICD-Build-Security
bash setup-pipeline-lab.sh
cd pipeline-lab
# Then open task2-ppe-simulation.md
```

---

## Learning Path

```
Room 1 Task 1 → Room 1 Task 2 → Room 1 Task 3
      ↓
Room 2 Task 1 (setup first!) → Room 2 Task 2
      ↓
Room 3 Task 1 → Room 3 Task 2 (setup first!) → Room 3 Task 3
      ↓
MODULE2-FLAGS.md (check your total score)
```

---

## Flag Format

All flags follow the format: `THM{...}`

Total flags available: **46**

---

## Key Tools Used

| Tool | Purpose | Install |
|------|---------|---------|
| `git log -p -S` | Search git history | Built-in |
| `grep -r` | Search current files | Built-in |
| `sha256sum` | Verify artifact integrity | Built-in |
| `trufflehog` | Automated secret scanner | `pip install trufflehog` |
| `gitleaks` | Git secret scanner | `brew install gitleaks` |
| `cosign` | Container image signing | `brew install cosign` |
| `syft` | Generate SBOMs | `brew install syft` |
