# SAST — Static Application Security Testing

> **Room:** [https://tryhackme.com/room/sast](https://tryhackme.com/room/sast)
> **Module:** 3 — Security in the Pipeline
> **Difficulty:** Medium

## Overview

SAST = scanning source code for vulnerabilities **without running it**. This room covers what SAST does, how it differs from DAST, the techniques behind it (pattern matching, AST analysis, taint tracking), and tools like Semgrep, SonarQube, Bandit, and CodeQL.

---

## Key Concepts

### What is SAST?

**Static Application Security Testing** — analyses source code, bytecode, or binaries to find security flaws without executing the program.

It's the "shift-left" tool of choice — runs as soon as code is written, often inside the IDE or as a pre-commit hook.

### SAST vs DAST vs IAST

| Type | When | What it sees | Pros | Cons |
|------|------|--------------|------|------|
| **SAST** | At code time / in CI | Source code | Catches issues early; finds root cause; full coverage of code | False positives; misses runtime/config issues |
| **DAST** | Against running app | Live HTTP traffic | Fewer false positives; finds runtime issues | Late in lifecycle; only tests paths it explores |
| **IAST** | App running with instrumentation | Code + runtime | Combines benefits | Requires instrumentation; complex setup |
| **SCA** | Code time | Dependencies | Catches known CVEs in libs | Only as good as the database |

### How SAST works

#### 1. Pattern matching (regex/text)
Simplest approach — looks for risky strings.
```
Search for: eval(, exec(, system(, password=, AKIA[A-Z0-9]{16}
```
Cheap but produces lots of false positives.

#### 2. AST analysis
Builds an **Abstract Syntax Tree** of the code and looks for risky structures.

Example: detect calling `eval()` on user input — match the AST node where the argument is tainted from a request.

#### 3. Data flow / taint analysis
Tracks how data moves through the program:
- **Source** — where untrusted data enters (e.g., HTTP request)
- **Sink** — dangerous function (e.g., `eval`, `os.system`, SQL execute)
- **Sanitizer** — function that cleans input

If data flows from source to sink without passing a sanitizer → **vulnerability**.

#### 4. Control flow analysis
Walks all execution paths, finds unreachable code, missing checks, etc.

### Common findings

- **Injection** — SQLi, command injection, XSS, LDAP injection
- **Hardcoded secrets** — API keys, passwords in source
- **Insecure crypto** — MD5/SHA1 for passwords, hardcoded IVs, ECB mode
- **Insecure deserialization** — unsafe `pickle.loads`, Java deserialization
- **Path traversal** — `../../etc/passwd`
- **Weak random** — `Math.random()` for tokens, `random.random()` in Python for crypto
- **Missing input validation**
- **Use of dangerous functions** — `eval`, `system`, `gets`

### Limits of SAST

- **False positives** — flags safe code as vulnerable
- **False negatives** — misses real bugs (especially logic flaws)
- **No runtime context** — can't tell if a vulnerable function is actually reachable
- **Configuration issues invisible** — can't see misconfigured prod settings
- **Performance** — large codebases can take hours to scan

### SAST tools by language

| Tool | Type | Languages |
|------|------|-----------|
| **Semgrep** | Open source | 30+ languages, custom rules in YAML |
| **SonarQube** | Open core | Most major languages |
| **CodeQL** | GitHub | C/C++, Java, JS, Python, Go, Ruby, Swift |
| **Bandit** | Open source | Python only |
| **Brakeman** | Open source | Ruby on Rails |
| **gosec** | Open source | Go |
| **Checkmarx** | Commercial | Many languages |
| **Veracode** | Commercial | Many languages |
| **Fortify** | Commercial | Many languages |

### Where SAST runs

1. **In the IDE** — real-time linting (SonarLint, Semgrep VS Code extension)
2. **Pre-commit hook** — block bad code before commit
3. **In CI pipeline** — block bad code before merge
4. **On a schedule** — full repo scan nightly

### Reducing false positives

- Tune rules to your codebase
- Suppress known false positives with code comments
- Don't enable every rule on day one — start with high-confidence ones
- Calibrate severity levels

---

## Commands Cheatsheet

### Semgrep

```bash
# Install
brew install semgrep
# or
pip install semgrep

# Run with default rules
semgrep --config auto

# Run with specific ruleset
semgrep --config p/security-audit
semgrep --config p/owasp-top-ten
semgrep --config p/python

# Custom rule file
semgrep --config ./my-rules.yml ./my-code

# Output JSON
semgrep --config auto --json -o results.json

# Fail CI on findings
semgrep --config auto --error

# Scan only changed files (great for PRs)
semgrep --config auto --baseline-commit main
```

#### Sample Semgrep custom rule

```yaml
# my-rules.yml
rules:
  - id: dangerous-eval
    pattern: eval(...)
    message: "Avoid using eval() - it's dangerous with untrusted input"
    languages: [python, javascript]
    severity: ERROR
```

### Bandit (Python)

```bash
# Install
pip install bandit

# Scan a file
bandit my_app.py

# Scan a directory recursively
bandit -r ./my-project

# JSON output
bandit -r . -f json -o report.json

# Skip specific tests
bandit -r . --skip B101,B601

# Confidence and severity filters
bandit -r . -ll                 # only HIGH severity
bandit -r . -iii                # only HIGH confidence
```

### SonarQube

```bash
# Run via Docker
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community

# Open: http://localhost:9000  (admin/admin)

# Run scanner against a project (after creating it in UI)
sonar-scanner \
  -Dsonar.projectKey=my-app \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<token>
```

### CodeQL

```bash
# Install CLI from https://github.com/github/codeql-cli-binaries

# Create database for a Python project
codeql database create my-db --language=python --source-root=.

# Run a query suite
codeql database analyze my-db \
  --format=sarif-latest \
  --output=results.sarif \
  codeql/python-queries:codeql-suites/python-security-extended.qls
```

### gosec (Go)

```bash
# Install
go install github.com/securego/gosec/v2/cmd/gosec@latest

# Scan
gosec ./...

# Output JSON
gosec -fmt=json -out=results.json ./...
```

### Brakeman (Rails)

```bash
# Install
gem install brakeman

# Scan
brakeman

# Output to file
brakeman -o report.html
```

### Pre-commit hook example

`.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/returntocorp/semgrep
    rev: v1.45.0
    hooks:
      - id: semgrep
        args: ['--config', 'auto', '--error']

  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ['-c', '.bandit']
```

Then:
```bash
pip install pre-commit
pre-commit install
```

### GitHub Actions integration

```yaml
# .github/workflows/sast.yml
name: SAST
on: [push, pull_request]
jobs:
  semgrep:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: returntocorp/semgrep-action@v1
        with:
          config: p/security-audit
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — What is SAST?**
- Q: What does SAST stand for?
- A: `Static Application Security Testing`
- Q: Does SAST require the application to be running?
- A: `No`

**Task 3 — How SAST works**
- Q: What does AST stand for?
- A: `Abstract Syntax Tree`
- Q: What technique tracks user input from entry to dangerous function?
- A: `taint analysis` (or `data flow analysis`)
- Q: Where does untrusted data enter the application?
- A: `source`
- Q: Where does dangerous data execute?
- A: `sink`

**Task 4 — Practical**
- The room gives you a code snippet (typically Python) to scan with Bandit or Semgrep.
- Run:
```bash
bandit -r ./vulnerable-app
# or
semgrep --config auto ./vulnerable-app
```
- Common findings: hardcoded password, use of `eval`, SQL string concatenation, weak crypto.
- The flag is usually the CVE/CWE number or vulnerability name from the report.

**Task 5 — Tools**
- Q: Which SAST tool is open-source and Python-only?
- A: `Bandit`
- Q: Which open-source SAST tool uses YAML rules?
- A: `Semgrep`
- Q: Which SAST product is owned by GitHub?
- A: `CodeQL`

**Task 6 — Conclusion**
- Click to complete.

---

## Key Takeaways

1. SAST analyses source code without running it — finds bugs **early**.
2. Core techniques: pattern matching, **AST analysis**, **taint analysis**, control flow.
3. SAST → false positives are the trade-off. Tune rules to fit your codebase.
4. SAST is **complementary** to DAST/SCA — not a replacement.
5. Tools: **Semgrep, SonarQube, CodeQL, Bandit (Python), Brakeman (Rails), gosec (Go)**.
