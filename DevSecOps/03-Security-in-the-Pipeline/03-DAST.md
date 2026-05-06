# DAST — Dynamic Application Security Testing

> **Room:** [https://tryhackme.com/room/dastzap](https://tryhackme.com/room/dastzap)
> **Module:** 3 — Security in the Pipeline
> **Difficulty:** Medium

## Overview

DAST tests a **running** application from the outside — exactly how an attacker would. This room focuses on OWASP ZAP (the most popular open-source DAST tool), how to use it, and how to integrate DAST into your CI/CD pipeline.

---

## Key Concepts

### What is DAST?

**Dynamic Application Security Testing** — sends real HTTP requests to a running application and looks at the responses to find vulnerabilities. It's a black-box test — DAST doesn't see your source code.

### How DAST works

1. **Spider / crawl** — discover all URLs and endpoints by following links and submitting forms
2. **Scan** — send modified/malicious requests to each endpoint
3. **Analyse responses** — look for error messages, unexpected status codes, reflected payloads, timing differences
4. **Report** — list confirmed and probable vulnerabilities

### What DAST finds

- **SQL injection** — by injecting `' OR 1=1--` and watching for SQL errors or response differences
- **XSS** — by injecting `<script>alert(1)</script>` and checking if it reflects
- **Command injection** — `; whoami` and looking at responses
- **Path traversal** — `../../etc/passwd`
- **Open redirects** — `?next=//evil.com`
- **Authentication issues** — missing auth, weak session cookies
- **Security misconfigurations** — exposed admin panels, info disclosure
- **TLS/HTTPS issues** — weak ciphers, missing HSTS
- **CSRF** — missing tokens
- **Server-side issues** like SSRF and SSTI in some cases

### What DAST misses

- Logic flaws (race conditions, business logic abuse)
- Bugs in code paths the crawler never reaches
- Vulnerabilities behind authentication if not configured properly
- Issues only triggered by specific inputs the scanner doesn't try

### SAST vs DAST recap

| | SAST | DAST |
|---|------|------|
| Sees source code | Yes | No |
| Needs app running | No | Yes |
| Catches issues early | ✅ | ❌ |
| Runtime/config issues | ❌ | ✅ |
| False positives | High | Lower |
| Works without language support | ❌ | ✅ |

Use both — they cover different things.

### Popular DAST tools

| Tool | Notes |
|------|-------|
| **OWASP ZAP** | Free, open source, the industry standard |
| **Burp Suite** | Commercial (Pro), pen-tester favourite, Community ed. is free but limited |
| **Nikto** | Old but useful — quick web server scan |
| **Wapiti** | Open source, command-line |
| **Acunetix** | Commercial |
| **AppScan** | IBM, commercial |

### OWASP ZAP modes

#### 1. Standard (interactive)
Run ZAP as a desktop app, browse through your site with ZAP as proxy.

#### 2. Automated scan
Spider + active scan in one go. Useful for CI.

#### 3. API scan
Specifically for OpenAPI / Swagger APIs.

#### 4. Baseline scan (passive only)
Won't attack the app — just observes traffic. Safe to run against production.

#### 5. Full scan (active)
Sends payloads — only run against staging or test environments, never production.

### Spider vs Active Scan

- **Spider** — follows links to find all pages
- **AJAX Spider** — uses a real browser to find dynamically-loaded content
- **Active scan** — actually sends attack payloads to the discovered endpoints

You usually run Spider first, then Active Scan against the discovered URLs.

### Authentication in DAST

If your app has logged-in pages, you need to tell DAST how to log in and stay logged in:
- **Form-based** — record a login script
- **HTTP Basic** — provide creds in scanner config
- **Bearer token** — set `Authorization` header
- **Session cookie** — provide a valid cookie

ZAP's "Context" feature lets you configure all this.

### DAST in CI/CD

The "ZAP Baseline scan" is designed for CI:
- Passive scan only (safe)
- Runs in a Docker container
- Outputs HTML/XML/JSON reports
- Returns non-zero exit code if findings exceed a threshold

```bash
docker run -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t https://staging.example.com -r report.html
```

---

## Commands Cheatsheet

### OWASP ZAP — desktop / GUI

```bash
# Linux install
sudo snap install zaproxy --classic

# macOS
brew install --cask owasp-zap

# Or download .jar from zaproxy.org and run:
java -jar zap.jar
```

### ZAP automated scan via Docker

```bash
# Pull the image
docker pull ghcr.io/zaproxy/zaproxy:stable

# Baseline scan (passive)
docker run -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://target.example.com

# Save HTML report
docker run -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://target.example.com -r baseline-report.html

# Full active scan (only against authorised targets!)
docker run -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py -t http://target.example.com -r full-report.html

# API scan (give it the OpenAPI spec)
docker run -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py -t http://target.example.com/openapi.json -f openapi -r api-report.html
```

### ZAP CLI / API

```bash
# Start ZAP daemon mode
zap.sh -daemon -port 8080 -host 127.0.0.1 -config api.disablekey=true

# Spider a URL via API
curl "http://localhost:8080/JSON/spider/action/scan/?url=http://target.com"

# Active scan via API
curl "http://localhost:8080/JSON/ascan/action/scan/?url=http://target.com&recurse=true"

# Get scan progress
curl "http://localhost:8080/JSON/spider/view/status/?scanId=0"
curl "http://localhost:8080/JSON/ascan/view/status/?scanId=0"

# Export results
curl "http://localhost:8080/JSON/core/view/alerts/" > alerts.json
curl "http://localhost:8080/OTHER/core/other/htmlreport/" > report.html
```

### Burp Suite (alternative)

```bash
# Burp doesn't have a great CLI for active scanning (Pro only).
# Most people use it interactively as a proxy.

# Set Firefox proxy to 127.0.0.1:8080
# Browse the app — Burp captures traffic
# Right-click target → "Scan" (Pro)
```

### Nikto

```bash
# Install
sudo apt install nikto

# Quick scan
nikto -h http://target.example.com

# Save output
nikto -h http://target.example.com -o report.html -Format html

# Scan with HTTPS
nikto -h https://target.example.com -ssl
```

### GitHub Actions — ZAP Baseline

```yaml
# .github/workflows/dast.yml
name: DAST
on:
  schedule:
    - cron: '0 0 * * 1'   # Mondays 00:00
  workflow_dispatch:
jobs:
  zap_scan:
    runs-on: ubuntu-latest
    steps:
      - uses: zaproxy/action-baseline@v0.10.0
        with:
          target: 'https://staging.example.com'
          fail_action: true
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — What is DAST?**
- Q: What does DAST stand for?
- A: `Dynamic Application Security Testing`
- Q: Does DAST require the app to be running?
- A: `Yes`
- Q: Is DAST black-box or white-box?
- A: `black-box`

**Task 3 — Tools**
- Q: What's the most popular open-source DAST tool?
- A: `OWASP ZAP`
- Q: What's the popular commercial DAST/proxy tool?
- A: `Burp Suite`

**Task 4 — Spider vs Active Scan**
- Q: Which mode follows links to discover URLs?
- A: `Spider`
- Q: Which mode actually sends attack payloads?
- A: `Active Scan`
- Q: Which scan is safe to run on production?
- A: `Baseline` (passive)

**Task 5 — Practical: Run ZAP against the target**
- The room gives you a target URL.
- Steps:
  1. Open ZAP (or use the docker baseline scan)
  2. Quick Start → Automated Scan → enter URL → Attack
  3. Wait for spider + active scan to complete
  4. Look at the **Alerts** tab — vulnerabilities are listed by severity
  5. The flag is usually the name of the highest-severity vulnerability or a value found in the response of an exploited endpoint

Common high-severity findings: SQL Injection, XSS (Reflected/Persistent), Path Traversal, Command Injection.

```bash
# Quick way:
docker run -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://<target-ip>
```

**Task 6 — CI Integration**
- Q: Which ZAP scan type is designed for CI/CD pipelines?
- A: `Baseline` (Baseline Scan)

**Task 7 — Conclusion**
- Click to complete.

---

## Key Takeaways

1. DAST tests a **running** app from outside — black-box, no source code needed.
2. **Spider** discovers URLs; **Active Scan** sends payloads. Run them in that order.
3. **Baseline scan** is passive and safe for CI; **Full scan** is active and only for staging.
4. SAST and DAST find different things — use both.
5. Tools: **OWASP ZAP** (open source king), **Burp Suite** (commercial favourite), **Nikto** (quick scans).
