# Intro to Kubernetes

> **Room:** [https://tryhackme.com/room/introtok8s](https://tryhackme.com/room/introtok8s)
> **Module:** 4 — Container Security
> **Difficulty:** Medium

## Overview

Kubernetes (K8s) is the industry-standard container orchestrator. This room covers its architecture, core objects (Pods, Deployments, Services, etc.), how to interact with a cluster via `kubectl`, and a peek at K8s-specific security concerns.

---

## Key Concepts

### Why Kubernetes?

Docker is great for running a few containers on one host. But what if you need:
- 100 containers spread across 20 servers?
- Auto-restart when a container crashes?
- Auto-scaling based on traffic?
- Rolling updates with zero downtime?
- Service discovery — let containers find each other by name?
- Built-in secrets and config management?

That's Kubernetes.

### K8s architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Control Plane (Master)                │
│                                                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │ kube-API │  │ Scheduler│  │ Ctrl Mgr │  │  etcd   │ │
│  │  server  │  │          │  │          │  │ (data)  │ │
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
                            ▲
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
   │ Worker  │         │ Worker  │         │ Worker  │
   │  Node   │         │  Node   │         │  Node   │
   │         │         │         │         │         │
   │ kubelet │         │ kubelet │         │ kubelet │
   │ kube-px │         │ kube-px │         │ kube-px │
   │  Pods   │         │  Pods   │         │  Pods   │
   └─────────┘         └─────────┘         └─────────┘
```

#### Control Plane components
- **kube-apiserver** — the front door; everything talks to it
- **etcd** — the database; stores cluster state
- **kube-scheduler** — decides which node a new Pod runs on
- **kube-controller-manager** — runs controllers (e.g., reconciles desired state)
- **cloud-controller-manager** — interfaces with cloud APIs (in cloud K8s)

#### Worker node components
- **kubelet** — the agent that runs on every node and manages Pods
- **kube-proxy** — handles networking on each node
- **Container runtime** — containerd / CRI-O / Docker

### Core Kubernetes objects

#### Pod
- Smallest unit. One or more containers that share network and storage.
- Most pods have a single container; multi-container pods are for tightly-coupled helpers (sidecars).

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: app
      image: nginx:1.25.4
      ports:
        - containerPort: 80
```

#### Deployment
- Manages a set of identical Pods. Handles rolling updates, rollback, replicas.
- 99% of the time you create Deployments, not raw Pods.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:1.25.4
```

#### Service
- Stable network endpoint for a set of Pods. Pods come and go but the Service IP stays.
- Types:
  - `ClusterIP` — internal only (default)
  - `NodePort` — exposes on each node's IP at a static port
  - `LoadBalancer` — provisions a cloud load balancer
  - `ExternalName` — DNS alias

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

#### Ingress
- Exposes HTTP/HTTPS routes to the outside. Routes by hostname/path. Needs an ingress controller (nginx-ingress, Traefik, etc.).

#### ConfigMap
- Non-secret configuration as key-value pairs. Mounted as env vars or files.

#### Secret
- Like ConfigMap but for sensitive data. Base64-encoded by default (NOT encrypted!).
- For real security, enable encryption at rest in etcd, or use external secret managers (Vault, AWS Secrets Manager via External Secrets Operator).

#### Namespace
- Virtual cluster within a cluster. Used for separating environments / teams / apps.
- Default namespaces: `default`, `kube-system`, `kube-public`, `kube-node-lease`.

#### Volume / PersistentVolume / PersistentVolumeClaim
- **Volume** — storage attached to a Pod
- **PersistentVolume (PV)** — cluster-wide storage resource
- **PersistentVolumeClaim (PVC)** — a Pod's request for a PV

#### DaemonSet
- Runs one Pod per node. Used for monitoring agents, log collectors.

#### StatefulSet
- Like a Deployment but with stable identities and ordered deployment. For databases, etc.

#### Job / CronJob
- Run-to-completion tasks. CronJob runs on a schedule.

### How a deployment "happens"

1. You run `kubectl apply -f deployment.yaml`
2. kubectl talks to **kube-apiserver**
3. apiserver validates and stores the spec in **etcd**
4. **Deployment controller** notices new Deployment, creates a ReplicaSet
5. **ReplicaSet controller** creates Pods to match the desired count
6. **Scheduler** picks a node for each Pod
7. **kubelet** on each chosen node pulls the image and starts the container
8. **kube-proxy** sets up networking so the Service can reach the Pods

### K8s security topics (preview)

Goes deeper in Container Vulnerabilities and Container Hardening rooms, but key terms:
- **RBAC (Role-Based Access Control)** — controls who can do what in the cluster
- **Service Accounts** — identities used by Pods to talk to the API server
- **Network Policies** — firewalls between Pods
- **Pod Security Standards** — replaces old PSPs; restricts pod capabilities
- **Admission controllers** — intercept and validate API requests (e.g., OPA/Gatekeeper, Kyverno)
- **Secrets** — base64 only by default, ALWAYS enable encryption at rest

### Common K8s distributions

- **Vanilla K8s** — install yourself with kubeadm
- **Minikube** — single-node K8s for laptops
- **Kind** — Kubernetes in Docker (great for testing)
- **k3s** — lightweight K8s, runs on a Pi
- **EKS / GKE / AKS** — managed K8s on AWS / GCP / Azure
- **OpenShift** — Red Hat's K8s distribution

---

## Commands Cheatsheet

### kubectl basics

```bash
# Cluster info
kubectl cluster-info
kubectl get nodes
kubectl get nodes -o wide
kubectl version

# Namespaces
kubectl get ns
kubectl create ns dev
kubectl config set-context --current --namespace=dev
```

### Workloads

```bash
# List pods
kubectl get pods
kubectl get pods -A                        # all namespaces
kubectl get pods -o wide
kubectl get pods --watch

# Describe (lots of detail)
kubectl describe pod <pod-name>

# Logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>                 # follow
kubectl logs <pod-name> -c <container>     # specific container in pod

# Exec into pod
kubectl exec -it <pod-name> -- bash
kubectl exec -it <pod-name> -c <container> -- sh

# Port-forward
kubectl port-forward pod/<pod-name> 8080:80
kubectl port-forward svc/<svc-name> 8080:80

# Apply / delete manifests
kubectl apply -f deployment.yaml
kubectl apply -f ./manifests/
kubectl delete -f deployment.yaml
kubectl delete pod <name>
kubectl delete pod <name> --grace-period=0 --force

# Scale a deployment
kubectl scale deployment web --replicas=5

# Update image
kubectl set image deployment/web nginx=nginx:1.26.0

# Rollout
kubectl rollout status deployment/web
kubectl rollout history deployment/web
kubectl rollout undo deployment/web
```

### Services & networking

```bash
kubectl get svc
kubectl describe svc <name>
kubectl get ingress

# Expose a deployment as a service
kubectl expose deployment web --port=80 --type=ClusterIP
```

### Config & secrets

```bash
# ConfigMap
kubectl create configmap app-config --from-literal=KEY=value
kubectl create configmap app-config --from-file=config.json
kubectl get cm
kubectl describe cm app-config

# Secret
kubectl create secret generic db-secret --from-literal=password=hunter2
kubectl get secrets
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 -d
```

### RBAC

```bash
kubectl get sa                              # service accounts
kubectl get roles
kubectl get rolebindings
kubectl get clusterroles
kubectl get clusterrolebindings

# Check what current user can do
kubectl auth can-i create pods
kubectl auth can-i delete deployments --all-namespaces
```

### Useful for security investigation

```bash
# What's running everywhere
kubectl get pods -A -o wide

# Find privileged pods
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}: {.spec.containers[*].securityContext.privileged}{"\n"}{end}'

# Get all images in use
kubectl get pods -A -o jsonpath='{range .items[*]}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' | sort -u

# See all service accounts and their tokens (sensitive!)
kubectl get sa -A
```

### Practical (for the room)

```bash
# Run a one-off pod for testing
kubectl run testpod --image=nginx --rm -it -- sh

# Apply provided manifest
kubectl apply -f /tmp/manifest.yaml

# Find a flag in a pod
kubectl exec -it <pod> -- cat /flag.txt
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — Architecture**
- Q: What component is the front door of the K8s API?
- A: `kube-apiserver`
- Q: What database stores cluster state?
- A: `etcd`
- Q: What runs on every worker node and manages pods?
- A: `kubelet`
- Q: What schedules pods onto nodes?
- A: `kube-scheduler`

**Task 3 — Core objects**
- Q: What's the smallest deployable unit in K8s?
- A: `Pod`
- Q: What manages a set of identical pods, with replicas and rolling updates?
- A: `Deployment`
- Q: What gives a stable network endpoint for pods?
- A: `Service`
- Q: What stores configuration (non-secret)?
- A: `ConfigMap`
- Q: What stores sensitive data?
- A: `Secret`
- Q: What virtual cluster mechanism separates environments?
- A: `Namespace`

**Task 4 — Service types**
- Q: Which service type is internal only?
- A: `ClusterIP`
- Q: Which service type provisions a cloud load balancer?
- A: `LoadBalancer`

**Task 5 — Practical: kubectl**
- Connect to the provided cluster:
```bash
kubectl get nodes
kubectl get pods -A
```
- Find the flag pod:
```bash
kubectl get pods -A | grep flag
kubectl logs <flag-pod> -n <namespace>
# or
kubectl exec -it <flag-pod> -n <ns> -- cat /flag.txt
```

**Task 6 — Conclusion**
- Click to complete.

---

## Key Takeaways

1. **Kubernetes orchestrates containers** across many nodes — auto-restart, scaling, rolling updates, service discovery.
2. **Control plane** (apiserver, etcd, scheduler, ctrl-mgr) + **worker nodes** (kubelet, kube-proxy, runtime) = a cluster.
3. **Pod** is the unit. **Deployments** manage Pods. **Services** give them stable endpoints.
4. **kubectl** is your CLI to the cluster. Master `get / describe / logs / exec / apply`.
5. **Secrets are NOT encrypted by default** — only base64. Enable encryption at rest.
