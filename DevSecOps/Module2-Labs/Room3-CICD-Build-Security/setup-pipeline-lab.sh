#!/bin/bash
# ============================================================
# Room 3 Lab Setup — CI/CD Build Security
# Usage: bash setup-pipeline-lab.sh
# ============================================================

set -e

LAB_DIR="$(pwd)/pipeline-lab"

if [ -d "$LAB_DIR" ]; then
  echo "[INFO] Lab already exists at $LAB_DIR"
  echo "[INFO] To reset: rm -rf $LAB_DIR && bash setup-pipeline-lab.sh"
  exit 0
fi

echo "[*] Creating pipeline lab at $LAB_DIR"
mkdir -p "$LAB_DIR"/{jenkins-sim,artifacts,tests}
cd "$LAB_DIR"

# ============================================================
# Mock Jenkins credentials store (Challenge 1)
# ============================================================
cat > jenkins-sim/credentials.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<com.cloudbees.plugins.credentials.SystemCredentialsProvider>
  <domainCredentialsMap class="hudson.util.CopyOnWriteMap$Hash">
    <entry>
      <com.cloudbees.plugins.credentials.domains.Domain>
        <specifications/>
      </com.cloudbees.plugins.credentials.domains.Domain>
      <java.util.concurrent.CopyOnWriteArrayList>

        <!-- GitHub deploy token -->
        <com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
          <id>github-deploy-token</id>
          <description>GitHub Actions deploy token</description>
          <username>acmecorp-ci</username>
          <password>{AQAAABAAAAAgfake_encrypted_github_pat_ghp_abc123XYZ}</password>
        </com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>

        <!-- AWS credentials -->
        <com.cloudbees.aws.credentials.impl.AWSCredentialsImpl>
          <id>aws-prod-deploy</id>
          <description>AWS production deployment credentials</description>
          <accessKey>AKIAIOSFODNN7EXAMPLE</accessKey>
          <secretKey>{AQAAABAAAAAgfake_encrypted_aws_secret}</secretKey>
        </com.cloudbees.aws.credentials.impl.AWSCredentialsImpl>

        <!-- Jenkins API token - FLAG HERE -->
        <jenkins.security.ApiTokenProperty>
          <id>jenkins-api-token</id>
          <description>Jenkins internal API token</description>
          <secret>THM{J3nk1ns_Cr3d3nt14ls_XML_Exf1ltr4t3d}</secret>
        </jenkins.security.ApiTokenProperty>

        <!-- Kubernetes config -->
        <org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl>
          <id>kubeconfig-prod</id>
          <description>Production Kubernetes config</description>
          <filename>kubeconfig</filename>
        </org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl>

      </java.util.concurrent.CopyOnWriteArrayList>
    </entry>
  </domainCredentialsMap>
</com.cloudbees.plugins.credentials.SystemCredentialsProvider>
EOF

# ============================================================
# Makefile (Challenge 2 - Indirect PPE target)
# ============================================================
cat > Makefile << 'EOF'
.PHONY: build test deploy clean

build:
	@echo "[*] Building application..."
	@python3 -c "print('Build successful')"

test:
	@echo "[*] Running tests..."
	@python3 -m pytest tests/ -v 2>/dev/null || python3 -c "print('Tests passed (3/3)')"

deploy:
	@echo "[*] Deploying to production..."
	@echo "[*] Deploy complete"

clean:
	@rm -rf __pycache__ *.pyc
EOF

# ============================================================
# Fake secrets file (simulates CI environment secrets)
# ============================================================
cat > pipeline-secrets.env << 'EOF'
# CI/CD Pipeline Secrets
# These are injected by Jenkins as environment variables
# An attacker achieving I-PPE via Makefile would exfiltrate these

DEPLOY_KEY=deploy_key_abc123_very_secret
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYSECRETKEY
KUBE_CONFIG_DATA=base64encodedkubeconfigdata...
DATABASE_PASSWORD=Sup3rS3cur3Pr0dP@ss
SLACK_TOKEN=xoxb-slack-notification-token

# The flag you're looking for:
EXFILTRATED_FLAG=THM{1nd1r3ct_PPE_M4k3f1le_Exf1ltr4t10n}
EOF

# ============================================================
# Vulnerable Jenkinsfile (Challenge 3)
# ============================================================
cat > Jenkinsfile << 'JEOF'
pipeline {
    agent any

    environment {
        // Secrets injected from Jenkins credential store
        AWS_CREDS = credentials('aws-prod-deploy')
        DEPLOY_KEY = credentials('github-deploy-token')
        KUBE_CONFIG = credentials('kubeconfig-prod')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'make build'
            }
        }

        stage('Test') {
            steps {
                sh 'make test'
            }
        }

        // VULNERABILITY: Debug stage left in production pipeline
        stage('Debug Info') {
            steps {
                // Reads Jenkins master key — anyone with log access gets it
                sh 'cat /var/lib/jenkins/secrets/master.key || true'
                // Dumps ALL env vars including injected secrets
                sh 'env'
                // Prints build machine info useful for pivoting
                sh 'cat /etc/passwd'
                sh 'id && whoami && hostname'
            }
        }

        stage('Package') {
            steps {
                sh 'tar -czf app-build.tar.gz src/'
                sh 'sha256sum app-build.tar.gz > app-build.tar.gz.sha256'
            }
        }

        stage('Deploy') {
            steps {
                // No artifact integrity check before deploy
                sh '''
                    export KUBECONFIG=${KUBE_CONFIG}
                    kubectl apply -f k8s/ --namespace production
                '''
            }
        }
    }

    post {
        always {
            // Publishes full build log including any leaked secrets
            archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
        }
    }
}
JEOF

# ============================================================
# Fake build artifact (Challenge 4 - Artifact Tampering)
# ============================================================

# "Real" artifact from build
echo "ACME Corp Application v1.0.0 - LEGITIMATE BUILD" > artifacts/app-v1.0.0.jar
echo "THM{Ver1fy_Art1f4ct_Sh4_B3for3_D3ploy}" >> artifacts/app-v1.0.0.jar

# Store the REAL hash (as if the build server signed it)
sha256sum artifacts/app-v1.0.0.jar | awk '{print $1}' > artifacts/app-v1.0.0.jar.REAL_SHA256

# Tamper with the artifact (attacker swaps it between build and deploy)
echo "ACME Corp Application v1.0.0 - TAMPERED BY ATTACKER" > artifacts/app-v1.0.0.jar
echo "malicious_payload_here" >> artifacts/app-v1.0.0.jar

# The sha256 file still has the OLD hash (from before tampering)
cp artifacts/app-v1.0.0.jar.REAL_SHA256 artifacts/app-v1.0.0.jar.sha256

echo "" > artifacts/README.txt
echo "Challenge: Compare the two SHA256 files" >> artifacts/README.txt
echo "app-v1.0.0.jar.sha256      = SHA256 recorded at BUILD TIME" >> artifacts/README.txt
echo "app-v1.0.0.jar.REAL_SHA256 = SHA256 recorded at BUILD TIME (backup)" >> artifacts/README.txt
echo "Run: sha256sum app-v1.0.0.jar  to see the CURRENT hash (post-tampering)" >> artifacts/README.txt

# ============================================================
# Vulnerable vs Hardened pipeline YAML (Challenge 5)
# ============================================================
cat > vulnerable-pipeline.yml << 'EOF'
name: Deploy

on:
  push:
    branches: [main]

permissions:
  contents: write-all

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4                        # floating tag
      - uses: actions/setup-node@v3                      # floating tag
        with:
          node-version: '18'
      - run: npm install
      - run: npm test
      - name: Deploy
        run: ./deploy.sh --api-key ${{ secrets.API_KEY }} --env production
      - name: Debug
        run: echo "Deployed with ${{ secrets.API_KEY }}"   # secret in log
EOF

cat > hardened-pipeline.yml << 'EOF'
name: Deploy

on:
  push:
    branches: [main]

# Minimum required permissions
permissions:
  contents: read
  packages: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      # Pinned to immutable SHA (not floating tag)
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
      - uses: actions/setup-node@1a4442cacd436585916779262731d1f68fb5b8c5  # v3.8.0
        with:
          node-version: '18'

      - run: npm ci --ignore-scripts        # --ignore-scripts prevents lifecycle PPE

      - run: npm test

      - name: Deploy
        # Secret injected as env var — masked in logs
        # NOT interpolated inline in the command
        env:
          API_KEY: ${{ secrets.API_KEY }}
        run: ./deploy.sh --env production

      - name: Verify artifact before deploy
        run: |
          EXPECTED=$(cat dist/app.sha256)
          ACTUAL=$(sha256sum dist/app.js | awk '{print $1}')
          [ "$EXPECTED" = "$ACTUAL" ] || (echo "Integrity check failed!" && exit 1)
EOF

# ============================================================
# Simple test file
# ============================================================
cat > tests/test_app.py << 'EOF'
def test_addition():
    assert 1 + 1 == 2

def test_string():
    assert "pipeline" in "pipeline security"

def test_flag_awareness():
    # A developer who knows about PPE
    dangerous_patterns = ["eval(", "exec(", "os.system(", "subprocess.call("]
    code = open("Makefile").read()
    for pattern in dangerous_patterns:
        assert pattern not in code, f"Dangerous pattern found: {pattern}"
EOF

echo ""
echo "============================================================"
echo " Pipeline lab created at: $LAB_DIR"
echo ""
echo " Files:"
ls -la
echo ""
echo " Start with: task2-ppe-simulation.md"
echo "============================================================"
