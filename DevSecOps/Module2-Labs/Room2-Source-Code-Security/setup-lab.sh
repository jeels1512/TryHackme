#!/bin/bash
# ============================================================
# Room 2 Lab Setup — Source Code Security
# Run this once to create the vulnerable git repo for the lab.
# Usage: bash setup-lab.sh
# ============================================================

set -e

LAB_DIR="$(pwd)/acmecorp-webapp"

if [ -d "$LAB_DIR" ]; then
  echo "[INFO] Lab repo already exists at $LAB_DIR"
  echo "[INFO] To reset: rm -rf $LAB_DIR && bash setup-lab.sh"
  exit 0
fi

echo "[*] Creating lab repository: $LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

git init -q
git config user.email "dev@acmecorp.com"
git config user.name "ACME Developer"

# ============================================================
# COMMIT 1 — Initial project scaffold (clean)
# ============================================================
mkdir -p src config tests

cat > src/app.py << 'PYEOF'
from flask import Flask, request, jsonify
import os

app = Flask(__name__)

@app.route('/api/users', methods=['GET'])
def get_users():
    return jsonify({"users": []})

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
PYEOF

cat > requirements.txt << 'EOF'
flask==2.3.2
requests==2.31.0
boto3==1.28.0
psycopg2-binary==2.9.7
EOF

cat > README.md << 'EOF'
# ACME Corp Web Application

Internal web application for ACME Corp.

## Setup
1. Install dependencies: `pip install -r requirements.txt`
2. Configure environment variables (see .env.example)
3. Run: `python src/app.py`
EOF

cat > .env.example << 'EOF'
# Copy this to .env and fill in real values
DATABASE_URL=postgresql://user:password@localhost/acmedb
AWS_ACCESS_KEY_ID=your_key_here
AWS_SECRET_ACCESS_KEY=your_secret_here
JWT_SECRET=your_jwt_secret_here
EOF

cat > .gitignore << 'EOF'
__pycache__/
*.pyc
*.pyo
*.egg-info/
dist/
build/
.pytest_cache/
EOF

git add .
git commit -q -m "Initial project scaffold"

# ============================================================
# COMMIT 2 — Add database connection module (clean)
# ============================================================
cat > src/database.py << 'PYEOF'
import psycopg2
import os

def get_connection():
    return psycopg2.connect(os.environ.get("DATABASE_URL"))

def query(sql, params=None):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(sql, params)
    results = cursor.fetchall()
    conn.close()
    return results
PYEOF

git add .
git commit -q -m "Add database connection module"

# ============================================================
# COMMIT 3 — Developer accidentally commits .env with real secrets
#             FLAG 1 is hidden here
# ============================================================
cat > .env << 'ENVEOF'
# ACME Corp Production Environment Variables
# DO NOT COMMIT THIS FILE

DATABASE_URL=postgresql://acme_admin:Sup3rS3cur3DBp@ss!@prod-db.acmecorp.internal:5432/acmedb_prod

AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYSECRETKEY

JWT_SECRET=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.secret.key

STRIPE_SECRET_KEY=sk_live_51NxTHM_flag1_THM{D0t_Env_F1l3_L3aked_S3cr3ts}

SENDGRID_API_KEY=SG.acmecorp.prod.mailkey.abc123

SLACK_WEBHOOK=https://hooks.slack.com/services/T00000/B00000/XXXXXXXXXXXXXXX
ENVEOF

git add .env
git commit -q -m "Add environment configuration"

# ============================================================
# COMMIT 4 — Developer realises the mistake and removes .env
#             But the secret is STILL IN HISTORY
# ============================================================
git rm -q .env
echo ".env" >> .gitignore
echo "*.env" >> .gitignore

git add .gitignore
git commit -q -m "Remove .env from repo and add to gitignore (oops)"

# ============================================================
# COMMIT 5 — Add AWS S3 integration (hardcoded key again, different one)
#             FLAG 2 is hidden here
# ============================================================
cat > src/storage.py << 'PYEOF'
import boto3

# TODO: move to env vars before code review
# Temporary hardcoded for local testing - Jake
AWS_KEY = "AKIAI44QH8DHBEXAMPLE"
AWS_SECRET = "je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY"
BUCKET = "acmecorp-prod-assets"

# FLAG: THM{H4rdC0d3d_AWS_K3y_1n_Src_C0d3}

def upload_file(filename, content):
    s3 = boto3.client(
        's3',
        aws_access_key_id=AWS_KEY,
        aws_secret_access_key=AWS_SECRET
    )
    s3.put_object(Bucket=BUCKET, Key=filename, Body=content)

def download_file(filename):
    s3 = boto3.client(
        's3',
        aws_access_key_id=AWS_KEY,
        aws_secret_access_key=AWS_SECRET
    )
    response = s3.get_object(Bucket=BUCKET, Key=filename)
    return response['Body'].read()
PYEOF

git add .
git commit -q -m "Add S3 storage integration"

# ============================================================
# COMMIT 6 — Developer commits SSH private key by mistake
#             FLAG 3 is hidden here
# ============================================================
mkdir -p deploy/keys

cat > deploy/keys/deploy_rsa << 'KEYEOF'
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA0Z3VS5JJcds3xHn/ygWep4PAtEsHAA2CVMG9pHCRa6E3hMkS
lHAPMGMkMWXsNgkHJCAfkMnlEF7DBCiGBQCMXqpbMpFrMHR4xHHCl2TCAKQmCBJ
ACME_CORP_DEPLOY_KEY_PROD_2024
THM{SSH_Pr1v4t3_K3y_C0mm1tt3d_T0_R3p0}
9dlNVMuOTjMEBTfBhU4Nl9IH5f1EUJHklXbTxYqBgORNhIp1jT0QLfLrSWFUW1
....(truncated for lab purposes)....
-----END RSA PRIVATE KEY-----
KEYEOF

git add deploy/keys/deploy_rsa
git commit -q -m "Add deployment keys for CI/CD runner"

# ============================================================
# COMMIT 7 — Tries to clean up the key again
# ============================================================
git rm -q deploy/keys/deploy_rsa
git commit -q -m "Remove private key (should not have been committed)"

# ============================================================
# COMMIT 8 — Normal feature work (clean)
# ============================================================
cat > src/auth.py << 'PYEOF'
import jwt
import os
from datetime import datetime, timedelta

def generate_token(user_id: int) -> str:
    payload = {
        "user_id": user_id,
        "exp": datetime.utcnow() + timedelta(hours=24)
    }
    return jwt.encode(payload, os.environ.get("JWT_SECRET"), algorithm="HS256")

def verify_token(token: str) -> dict:
    return jwt.decode(token, os.environ.get("JWT_SECRET"), algorithms=["HS256"])
PYEOF

git add .
git commit -q -m "Add JWT authentication module"

# ============================================================
# COMMIT 9 — Config file with database password
#             FLAG 4 hidden here
# ============================================================
cat > config/database.yml << 'YAMLEOF'
# Database configuration
# Generated by setup script on 2024-01-15

production:
  adapter: postgresql
  host: prod-db.acmecorp.internal
  port: 5432
  database: acmedb_prod
  username: acme_admin
  password: "THM{DB_P4ssw0rd_1n_C0nf1g_Y4ml}"
  pool: 10
  timeout: 5000

staging:
  adapter: postgresql
  host: staging-db.acmecorp.internal
  port: 5432
  database: acmedb_staging
  username: acme_staging
  password: "staging_pass_abc123"
  pool: 5
YAMLEOF

git add .
git commit -q -m "Add database configuration for all environments"

# ============================================================
# COMMIT 10 — Final clean state (current HEAD is "clean" looking)
# ============================================================
cat > src/utils.py << 'PYEOF'
import hashlib
import secrets

def hash_password(password: str) -> str:
    salt = secrets.token_hex(16)
    return hashlib.sha256(f"{salt}{password}".encode()).hexdigest()

def verify_password(password: str, hashed: str) -> bool:
    # Proper implementation would store salt separately
    return False  # TODO: implement properly
PYEOF

git add .
git commit -q -m "Add utility functions"

echo ""
echo "============================================================"
echo " Lab repository created successfully!"
echo " Location: $LAB_DIR"
echo ""
echo " Git log:"
git log --oneline
echo ""
echo " Start the lab: open task1-find-secrets.md"
echo "============================================================"
