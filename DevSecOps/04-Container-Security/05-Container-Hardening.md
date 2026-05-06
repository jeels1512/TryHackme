# Container Hardening

> **Room:** [https://tryhackme.com/room/containerhardening](https://tryhackme.com/room/containerhardening)
> **Module:** 4 — Container Security
> **Difficulty:** Medium

## Overview

This room is the practical companion to the Vulnerabilities room. It teaches how to **build, configure, and run containers securely** — multi-stage builds, non-root users, minimal images, capabilities, seccomp, AppArmor, image signing, and Kubernetes security contexts.

---

## Key Concepts

### The hardening principles

1. **Least privilege** — only give the container what it needs
2. **Minimal attack surface** — smallest possible image
3. **Immutable infrastructure** — images are versioned and never modified after build
4. **Defence in depth** — multiple layers (image scanning + runtime restrictions + monitoring)
5. **Continuous patching** — rebuild and redeploy with new bases regularly

### Hardening the image

#### Use minimal base images

| Base | Size | Notes |
|------|------|-------|
| `ubuntu:22.04` | ~80 MB | Full distro, lots of utilities (= attack surface) |
| `debian:slim` | ~30 MB | Slimmer Debian |
| `alpine:3.19` | ~5 MB | Tiny, popular, but uses musl libc (some compatibility issues) |
| `distroless` | ~2-20 MB | No shell, no package manager, just your app + runtime |
| `scratch` | 0 MB | Empty — for static binaries (Go, Rust) |

**`distroless` example:**
```dockerfile
FROM gcr.io/distroless/python3-debian12
COPY app.py /
CMD ["app.py"]
```
No `bash`, no `apt`, no shell — much harder for an attacker to do anything useful even if they get RCE.

#### Multi-stage builds

Keep build tools out of the final image.

```dockerfile
# --- Build stage ---
FROM golang:1.22 AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -o /out/app

# --- Runtime stage ---
FROM gcr.io/distroless/static
COPY --from=builder /out/app /app
USER nonroot:nonroot
ENTRYPOINT ["/app"]
```

The final image only contains the compiled binary — no Go toolchain, no source code.

#### Don't run as root

```dockerfile
# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos "" appuser
USER appuser

# Or use a numeric UID (works even on distroless)
USER 1000:1000
```

#### Pin versions

Bad: `FROM nginx:latest` — can change anytime, no reproducibility.
Good: `FROM nginx:1.25.4-alpine`
Best: `FROM nginx@sha256:abc123...` — pinned to exact image digest.

#### `.dockerignore`

Don't accidentally COPY your `.git` folder, secrets, or `node_modules` into the image.

```
.git
.env
.env.*
node_modules
*.log
.DS_Store
.vscode
README.md
```

#### Don't store secrets in images

```dockerfile
# BAD
ENV API_KEY=sk_live_abc123

# Also BAD - secret is in a layer even if you delete it later
RUN echo "secret" > /tmp/key && some-build-step && rm /tmp/key

# Good - use build-time secrets (BuildKit)
RUN --mount=type=secret,id=api_key API_KEY=$(cat /run/secrets/api_key) \
    some-build-step
```

#### Health checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/health || exit 1
```

### Hardening the runtime (Docker)

#### Drop all capabilities, add only needed ones

```bash
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE nginx
```

#### Read-only root filesystem

```bash
docker run --read-only --tmpfs /tmp myimage
```

#### Resource limits

```bash
docker run -m 256m --cpus=0.5 myimage
```

#### Drop privileges

```bash
# Don't allow gaining new privileges (e.g., via setuid binaries)
docker run --security-opt=no-new-privileges:true myimage

# Run with a specific user
docker run --user 1000:1000 myimage
```

#### Use a custom seccomp profile

```bash
docker run --security-opt seccomp=./my-seccomp.json myimage
```

#### AppArmor / SELinux profile

```bash
docker run --security-opt apparmor=docker-default myimage
```

#### Don't expose Docker socket inside containers

Just don't. There's almost no legitimate reason.

### Hardening Kubernetes

#### Pod Security Standards

Three levels:
- **Privileged** — anything goes (default, bad)
- **Baseline** — minimum restrictions
- **Restricted** — heavily locked down

Apply per namespace:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: prod
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
```

#### `securityContext` on Pods/containers

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: app
      image: myapp:1.0
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop: ["ALL"]
          add: ["NET_BIND_SERVICE"]
      resources:
        limits:
          memory: "256Mi"
          cpu: "500m"
        requests:
          memory: "128Mi"
          cpu: "250m"
```

#### NetworkPolicy — pod-to-pod firewall

By default, every pod can talk to every other pod. NetworkPolicies fix that.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
```

Then allow only what you need.

#### RBAC — least privilege

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: app
  name: pod-reader
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
```

Don't use `cluster-admin` for app service accounts. Don't auto-mount service account tokens in pods that don't need them:
```yaml
spec:
  automountServiceAccountToken: false
```

#### Admission controllers

- **OPA / Gatekeeper** — policy as code
- **Kyverno** — Kubernetes-native policies
- Use them to enforce rules like "no privileged pods", "must have resource limits", "images must come from trusted registry".

### Image signing & verification

```bash
# Sign with cosign
cosign generate-key-pair
cosign sign --key cosign.key registry.example.com/myapp:1.0

# Verify before deploy
cosign verify --key cosign.pub registry.example.com/myapp:1.0
```

Pair with admission control to **only allow signed images** in your cluster.

### Continuous monitoring

- **Falco** — alerts on weird runtime behaviour (shell in container, unexpected file writes, etc.)
- **Tracee** — eBPF-based tracing
- **Sysdig Secure** — commercial
- Centralised logs (Loki / ELK / Splunk)
- Audit logs from K8s API server

---

## Commands Cheatsheet

### Build secure images

```bash
# Use BuildKit features (better caching, build secrets, multi-stage)
DOCKER_BUILDKIT=1 docker build -t myapp:1.0 .

# Build with secret without baking it into the image
docker build --secret id=api_key,src=./api_key.txt -t myapp:1.0 .

# Pin to a digest (most secure)
docker pull nginx:1.25.4
docker inspect --format '{{index .RepoDigests 0}}' nginx:1.25.4
# nginx@sha256:6af79ae5...
```

### Run hardened containers

```bash
# All-in-one secure run
docker run -d \
  --name myapp \
  --user 1000:1000 \
  --read-only \
  --tmpfs /tmp \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --security-opt=no-new-privileges:true \
  --security-opt seccomp=./seccomp.json \
  -m 256m --cpus=0.5 \
  -p 8080:8080 \
  myapp:1.0
```

### Scanning

```bash
# Trivy — full image scan
trivy image --severity HIGH,CRITICAL myapp:1.0

# Trivy — config scan (Dockerfile, K8s YAML)
trivy config ./Dockerfile
trivy config ./k8s/

# Hadolint — Dockerfile linter
docker run --rm -i hadolint/hadolint < Dockerfile

# Dockle — image linter for best practices
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  goodwithtech/dockle myapp:1.0
```

### Kubernetes auditing

```bash
# CIS K8s benchmark
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
kubectl logs -f job/kube-bench

# Polaris — best practices audit
kubectl apply -f https://github.com/FairwindsOps/polaris/releases/latest/download/dashboard.yaml
kubectl port-forward --namespace polaris svc/polaris-dashboard 8080:80

# Kubescape — security posture
curl -s https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | /bin/bash
kubescape scan
```

### Generate seccomp profile

```bash
# Use Inspektor Gadget or oci-seccomp-bpf-hook to record syscalls,
# then use the recorded profile for production
docker run --security-opt seccomp=audit.json myapp
# review syscalls used, build a tighter profile
```

### Sign and verify with Cosign

```bash
cosign generate-key-pair
cosign sign --key cosign.key registry.example.com/myapp:1.0
cosign verify --key cosign.pub registry.example.com/myapp:1.0

# Keyless signing (uses OIDC + transparency log)
cosign sign registry.example.com/myapp:1.0
```

### SBOM generation

```bash
syft myapp:1.0 -o spdx-json > sbom.spdx.json
syft myapp:1.0 -o cyclonedx-json > sbom.cdx.json

# Attach SBOM to image with Cosign
cosign attach sbom --sbom sbom.spdx.json registry.example.com/myapp:1.0
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — Hardening the image**
- Q: What technique uses separate stages so build tools aren't in the final image?
- A: `multi-stage builds`
- Q: What's the most minimal base image type with no shell?
- A: `distroless` (or `scratch` for static binaries)
- Q: What user should you NOT run a container as?
- A: `root`

**Task 3 — Hardening the runtime**
- Q: What flag drops all Linux capabilities?
- A: `--cap-drop=ALL`
- Q: What flag makes the root filesystem read-only?
- A: `--read-only`
- Q: What security feature filters allowed syscalls?
- A: `seccomp`

**Task 4 — Kubernetes hardening**
- Q: What field on a pod/container sets security options?
- A: `securityContext`
- Q: What sets `runAsNonRoot: true` enforce?
- A: `pod must run as a non-root user`
- Q: What K8s resource implements pod-to-pod firewalling?
- A: `NetworkPolicy`

**Task 5 — Image signing**
- Q: What tool signs container images?
- A: `Cosign` (or `Sigstore`)

**Task 6 — Practical**
- The room may give you a Dockerfile or K8s manifest with security issues to fix.
- Common fixes:
  1. Switch to a smaller base (`alpine` / `distroless`)
  2. Add `USER` directive (non-root)
  3. Use multi-stage build
  4. Add `securityContext` with `runAsNonRoot`, `readOnlyRootFilesystem`, `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`
  5. Pin the image version
  6. Remove `--privileged`, remove Docker socket mount
- Run a scanner (`trivy`, `dockle`) before/after to see the improvement.
- Flag is usually obtained by deploying the hardened version, or output by a checking script.

**Task 7 — Conclusion**
- Click to complete.

---

## Key Takeaways

1. **Smallest possible image + non-root user + multi-stage build** = solid baseline.
2. At runtime: drop all capabilities, read-only filesystem, no-new-privileges, resource limits.
3. In K8s: use **`securityContext`**, **NetworkPolicy**, **Pod Security Standards**, RBAC least-privilege.
4. **Sign images with Cosign**, generate SBOMs with Syft, scan with Trivy.
5. Hardening is layered — image hardening + runtime restrictions + monitoring (Falco).
