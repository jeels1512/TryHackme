# Room 3 — Task 2: PPE Attack Simulation (Hands-On)

## Setup

```bash
cd /home/user/TryHackme/DevSecOps/Module2-Labs/Room3-CICD-Build-Security
bash setup-pipeline-lab.sh
cd pipeline-lab
```

This creates a simulated pipeline environment with:
- A `Jenkinsfile` with a hidden flag in the credentials
- A `Makefile` vulnerable to Indirect PPE
- A fake "secrets" environment

---

## Challenge 1 — Read Jenkins Credentials (Simulated)

In a real Jenkins compromise you'd use the Script Console to decrypt credentials.  
Here we simulate it by reading the mock credential store.

```bash
cat jenkins-sim/credentials.xml
```

**Q: What is the Jenkins API token stored in credentials.xml?**

<details>
<summary>Hint</summary>
Look for the `<secret>` tag inside the credentials XML.
</details>

<details>
<summary>Answer + Flag</summary>

```xml
<secret>THM{J3nk1ns_Cr3d3nt14ls_XML_Exf1ltr4t3d}</secret>
```

In a real attack you'd run this in Jenkins Script Console:
```groovy
println(hudson.util.Secret.decrypt("{ENCRYPTED_VALUE}"))
```

**Flag:** `THM{J3nk1ns_Cr3d3nt14ls_XML_Exf1ltr4t3d}`
</details>

---

## Challenge 2 — Indirect PPE via Makefile

The pipeline runs `make test` as part of CI.  
Simulate an Indirect PPE attack by modifying the Makefile to exfiltrate the "secret".

```bash
# View the current Makefile
cat Makefile

# View the fake secret in the environment
cat pipeline-secrets.env
```

**Your task:** Modify the `test` target in the Makefile so that when `make test` runs, it also prints the contents of `pipeline-secrets.env` (simulating what an attacker would exfiltrate).

<details>
<summary>Step-by-step attack simulation</summary>

```bash
# Step 1: View what the pipeline has access to
cat pipeline-secrets.env

# Step 2: Modify the Makefile test target (simulated I-PPE)
# Edit Makefile, change the test target to:
#   test:
#       python3 -m pytest tests/ && cat pipeline-secrets.env

# Step 3: "Run CI" — simulate what the pipeline would do
make test

# The flag appears in the output as if it was exfiltrated
```

**Flag:** `THM{1nd1r3ct_PPE_M4k3f1le_Exf1ltr4t10n}` (revealed when you run make test after editing)
</details>

---

## Challenge 3 — Find the Flag in the Vulnerable Jenkinsfile

```bash
cat Jenkinsfile
```

There's a misconfigured stage in the Jenkinsfile that would allow an attacker to  
read the master key. Find the stage and identify the vulnerability.

**Q: Which stage in the Jenkinsfile reads a sensitive file without restriction?**

<details>
<summary>Answer + Flag</summary>

The "Debug" stage:
```groovy
stage('Debug Info') {
    steps {
        sh 'cat /var/lib/jenkins/secrets/master.key || true'
        sh 'env'   // dumps ALL environment variables including secrets
    }
}
```

- `cat /var/lib/jenkins/secrets/master.key` — exposes the master key used to decrypt ALL stored credentials
- `env` — dumps every environment variable, including any injected secrets, into the build log

**Flag:** `THM{Debug_Stage_Leaks_Master_Key_And_Env}`
</details>

---

## Challenge 4 — Artifact Tampering Scenario

```bash
ls -la artifacts/
cat artifacts/app-v1.0.0.jar.sha256
cat artifacts/app-v1.0.0.jar.REAL_SHA256
```

**Q: Has the artifact been tampered with? What should the deploy script check before deploying?**

<details>
<summary>Answer + Flag</summary>

The two SHA256 files contain different hashes — the artifact was tampered with between build and deploy.

The deploy script should:
```bash
# Verify artifact integrity before deploy
EXPECTED=$(cat app-v1.0.0.jar.sha256)
ACTUAL=$(sha256sum app-v1.0.0.jar | awk '{print $1}')

if [ "$EXPECTED" != "$ACTUAL" ]; then
    echo "INTEGRITY CHECK FAILED - artifact may be tampered!"
    exit 1
fi
```

Or using Cosign for signed container images:
```bash
cosign verify --key cosign.pub registry.acmecorp.com/app:v1.0.0
```

**Flag:** `THM{Ver1fy_Art1f4ct_Sh4_B3for3_D3ploy}`
</details>

---

## Challenge 5 — Harden This Workflow

Read `vulnerable-pipeline.yml` and then read `hardened-pipeline.yml`.  
Answer the questions below.

```bash
diff vulnerable-pipeline.yml hardened-pipeline.yml
```

**Q1: What specific change prevents a supply chain attack via a third-party action?**

<details>
<summary>Answer + Flag</summary>

Changing:
```yaml
- uses: actions/checkout@v4           # mutable tag
```
to:
```yaml
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # immutable SHA
```

A tag like `v4` can be moved to point to a different (malicious) commit. A SHA is permanently bound to a specific commit — it can never be changed.

**Flag:** `THM{Pin_To_SHA_Prevents_Supply_Chain_Attack}`
</details>

**Q2: What environment variable change prevents secrets from leaking into logs?**

<details>
<summary>Answer + Flag</summary>

The hardened version uses:
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}    # injected as env var — masked in logs
```

Instead of:
```yaml
run: ./deploy.sh --api-key ${{ secrets.API_KEY }}   # appears in shell command history and logs
```

GitHub Actions auto-masks values from `secrets.*` when they appear as env vars, but inline substitution in `run:` blocks can bypass masking.

**Flag:** `THM{Env_Var_Injection_Masks_Secrets_In_Logs}`
</details>

---

Move to → [task3-hardening.md](task3-hardening.md)
