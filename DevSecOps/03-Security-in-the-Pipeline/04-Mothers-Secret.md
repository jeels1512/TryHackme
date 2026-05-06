# Mother's Secret — Code Analysis Challenge

> **Room:** [https://tryhackme.com/room/codeanalysis](https://tryhackme.com/room/codeanalysis)
> **Module:** 3 — Security in the Pipeline
> **Difficulty:** Medium (Challenge)

## Overview

This is a **practical challenge room** — the capstone for Module 3. You're given a small web application's source code and asked to find vulnerabilities, exploit them, and capture flags. It tests everything from SAST and dependency scanning through to actual exploitation.

The "Mother's Secret" theme involves a fairy-tale-styled web app with security flaws baked in.

---

## Approach (general methodology)

Since this is a challenge room, the goal is to apply the techniques from earlier rooms. Here's the workflow:

### Step 1 — Get the source code
The room either provides a download or a link to a Git repo for the target.

```bash
# Clone or download
git clone <provided-url>
cd mothers-secret
```

### Step 2 — Inspect the structure
```bash
ls -la
cat README.md
cat package.json   # or requirements.txt, pom.xml, etc.
tree -L 2          # see folder structure
```

Note:
- What language is it written in?
- What framework? (Express? Flask? Django?)
- What dependencies are listed?

### Step 3 — Check Git history for secrets
```bash
git log --all --oneline
git log -p -S "password"
git log -p -S "key"
git log -p -S "secret"

# Use trufflehog or gitleaks
trufflehog filesystem .
gitleaks detect --source . -v
```

### Step 4 — Run dependency / SCA scan
```bash
# Node
npm audit

# Python
pip-audit -r requirements.txt
# or
safety check -r requirements.txt

# Generic
trivy fs .
```

### Step 5 — Run SAST
```bash
# Universal
semgrep --config auto .

# Python-specific
bandit -r .

# Look for:
# - eval / exec / system calls on user input
# - SQL string concatenation
# - Hardcoded secrets
# - Weak crypto (MD5, SHA1 for passwords)
# - Insecure deserialization
```

### Step 6 — Manual code review
Read the source — focus on:
- **Auth code** — login routes, password hashing, session/token generation
- **Routes that take user input** — query params, form bodies, headers
- **Database queries** — built with string concatenation? user input used directly?
- **File operations** — path traversal possible?
- **Comments** — devs sometimes leave clues like "TODO: remove debug endpoint"
- **Dotenv / config files** — secrets, default creds, debug flags

### Step 7 — Run the app and exploit
```bash
# Often Docker-based
docker compose up

# Or run directly
npm install && npm start
python app.py
```

Then test the vulnerabilities you found:
- Try default creds you found in source / git history
- Inject SQL into the login form: `' OR 1=1 --`
- Try XSS in input fields: `<script>alert(1)</script>`
- Try path traversal: `?file=../../../etc/passwd`
- Hit any "debug" or admin routes you found in code

---

## Common vulnerability patterns to look for

### Hardcoded credentials
```javascript
// Bad
const ADMIN_PASS = "supersecret123";
if (req.body.password === ADMIN_PASS) {
  // grant admin access
}
```

### SQL injection
```python
# Bad
cursor.execute(f"SELECT * FROM users WHERE name = '{username}'")
```

### Command injection
```python
# Bad
os.system(f"ping {user_input}")
```

### Insecure deserialization
```python
# Bad
data = pickle.loads(request.cookies['session'])
```

### Path traversal
```python
# Bad
with open(f"./uploads/{filename}", 'r') as f:
```

### JWT issues
- `none` algorithm allowed
- Hardcoded secret like `secret` or `changeme`
- No expiration

### IDOR (Insecure Direct Object Reference)
```javascript
// Bad — no ownership check
app.get('/api/orders/:id', (req, res) => {
  res.json(db.orders.findById(req.params.id));
});
```

---

## Commands Cheatsheet

```bash
# Full investigation pipeline
git clone <repo>
cd <repo>

# 1. Look around
ls -la && cat README.md && tree -L 2

# 2. Secrets in history
trufflehog filesystem . --only-verified
gitleaks detect --source . -v
git log -p --all | grep -iE "(password|secret|api[_-]?key|token)" | head -50

# 3. Dependency vulns
npm audit 2>/dev/null || pip-audit -r requirements.txt 2>/dev/null
trivy fs --severity HIGH,CRITICAL .

# 4. SAST
semgrep --config auto . --json -o semgrep.json
bandit -r . -ll 2>/dev/null

# 5. Run the app
docker compose up -d

# 6. Probe the running app
curl http://localhost:<port>/
nikto -h http://localhost:<port>

# 7. ZAP baseline (passive)
docker run -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://localhost:<port>
```

### Exploitation toolbox

```bash
# SQL injection probes
curl "http://target/login" -d "user=admin' OR 1=1--&pass=x"

# XSS probe
curl "http://target/search?q=<script>alert(1)</script>"

# Command injection
curl "http://target/api/ping?host=127.0.0.1;id"

# Path traversal
curl "http://target/file?name=../../../../etc/passwd"

# JWT decode (no validation, just show)
echo "<token>" | cut -d. -f2 | base64 -d

# Use jwt-cli to manipulate
jwt encode --alg HS256 --secret "secret" '{"user":"admin"}'
```

---

## Room Answers

This is a challenge room so flags are unique to your instance. The general flow:

**Task 1 — Read brief / set up**
- Download the source / connect to the machine.

**Task 2 — Find Flag 1 (often: a leaked secret)**
- Look in Git history with trufflehog/gitleaks.
- Check `.env`, `config.js`, comments in code.
- Common spots: a removed-but-still-in-history `.env` file, a hardcoded JWT secret, default admin creds.

**Task 3 — Find Flag 2 (often: SAST-found vuln)**
- Run Semgrep/Bandit, look for the highest-severity findings.
- Likely an injection or insecure deserialization the report points to.

**Task 4 — Find Flag 3 (often: dependency CVE)**
- Run `npm audit` / `pip-audit` / `trivy`.
- Identify a CVE in a dependency, then exploit it (e.g., a known RCE in an old library version).

**Task 5 — Find Flag 4 (often: exploitation flag)**
- Use the vulnerability you found to actually pwn the running app.
- Read a flag file at `/flag.txt` or similar.

> Because flags are dynamically generated per user, I can't list them. Run the commands in the cheatsheet, follow the trail, and you'll find them.

---

## Key Takeaways

1. **Layered analysis** wins challenges: source code → git history → dependencies → SAST → manual review → DAST → exploit.
2. Always check **Git history** — secrets removed in newer commits still live there.
3. SAST findings are leads — confirm them by reading the code in context.
4. Dependency vulnerabilities are easy wins — `npm audit` / `pip-audit` first.
5. The skills from earlier rooms (Source Code Security, Dependency Management, SAST, DAST) all apply here.
