# Intro to Containerisation

> **Room:** [https://tryhackme.com/room/introtocontainerisation](https://tryhackme.com/room/introtocontainerisation)
> **Module:** 4 — Container Security
> **Difficulty:** Easy

## Overview

Foundational room for the container module. It explains what containers are, how they differ from virtual machines, why everyone uses them now, and the underlying Linux features (namespaces, cgroups) that make them work.

---

## Key Concepts

### What is containerisation?

Containerisation **packages an application together with everything it needs to run** — code, runtime, libraries, config — into a single unit called a **container**.

The container runs in **isolation** from other containers and the host, but they all share the same OS kernel.

### Why containers?

- **Consistency** — "works on my machine" goes away. The container runs the same on a dev laptop, in CI, and in production.
- **Lightweight** — way smaller and faster to start than VMs.
- **Portable** — runs anywhere a container runtime is installed.
- **Scalable** — spin up 100 containers in seconds.
- **Isolation** — one buggy container doesn't bring down the host.

### Containers vs Virtual Machines

| | Containers | Virtual Machines |
|---|------------|------------------|
| Kernel | Shared with host | Each VM has its own |
| Boot time | Seconds | Minutes |
| Size | MBs | GBs |
| Isolation | Process-level | Hardware-level (stronger) |
| Performance | Near-native | Some overhead |
| Use case | Modern apps, microservices | Full OS isolation, legacy apps |

VMs run on a **hypervisor** (VMware, Hyper-V, KVM). Each VM has a full guest OS.
Containers run on a **container runtime** (Docker, containerd, CRI-O). They share the host kernel.

### How containers work — Linux building blocks

Containers aren't a single feature. They're a combination of Linux kernel features:

#### 1. Namespaces
Provide isolation. Each container gets its own:
- **PID namespace** — its own process IDs (PID 1 inside ≠ PID 1 outside)
- **NET namespace** — its own network interfaces
- **MNT namespace** — its own filesystem mounts
- **UTS namespace** — its own hostname
- **IPC namespace** — its own inter-process communication
- **USER namespace** — its own user/group ID mappings

#### 2. Cgroups (control groups)
Limit resources — CPU, memory, disk I/O, network. Stops one container from hogging everything.

#### 3. Union filesystems (OverlayFS, etc.)
Let containers share read-only layers. The image is read-only; changes happen in a thin writeable layer on top. This is why container images are so small and fast to start.

#### 4. Capabilities
Linux splits root privileges into ~40 fine-grained capabilities (CAP_NET_BIND_SERVICE, CAP_SYS_ADMIN, etc.). Containers can be given just the ones they need — rather than full root.

#### 5. Seccomp
Filters which syscalls a container can make. Most containers don't need the full ~300+ syscalls.

#### 6. AppArmor / SELinux
Mandatory Access Control profiles that further restrict what a container can do.

### Key terminology

- **Image** — a read-only template (like a blueprint)
- **Container** — a running instance of an image
- **Registry** — where images are stored (Docker Hub, GHCR, Quay, etc.)
- **Tag** — a version/label on an image (`nginx:1.25.4`, `nginx:latest`)
- **Layer** — images are made of stacked filesystem layers
- **Volume** — persistent storage attached to a container
- **Network** — virtual network connecting containers

### Container ecosystem

- **Docker** — the most well-known runtime + tooling
- **containerd** — the runtime Docker actually uses under the hood; also used by Kubernetes
- **CRI-O** — alternative runtime designed specifically for Kubernetes
- **Podman** — Docker-compatible, daemonless, can run rootless
- **Kubernetes** — orchestrates many containers across many machines
- **Docker Compose** — orchestrates a few containers on one machine

---

## Commands Cheatsheet

This room is mostly conceptual, but here are the related commands you'll use later:

```bash
# Check if you have Docker
docker --version

# See running containers
docker ps

# See all containers
docker ps -a

# See images
docker images

# Run a container
docker run -it ubuntu bash

# Look at namespaces on Linux
ls -la /proc/$$/ns

# See cgroup limits for a process
cat /proc/$$/cgroup
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — Why containers?**
- Q: What's the main advantage of containers over VMs in terms of size?
- A: `lightweight` (containers are much smaller than VMs)

**Task 3 — Containers vs VMs**
- Q: Do containers share the host's kernel?
- A: `Yes`
- Q: Do VMs share the host's kernel?
- A: `No`
- Q: Which has a longer boot time?
- A: `Virtual machines` (or `VMs`)

**Task 4 — How containers work**
- Q: What Linux feature isolates processes between containers?
- A: `namespaces`
- Q: What Linux feature limits resource use (CPU, memory)?
- A: `cgroups` (or `control groups`)

**Task 5 — Terminology**
- Q: A read-only template used to create containers is called?
- A: `image`
- Q: Where are images stored?
- A: `registry`

**Task 6 — Conclusion**
- Click to complete.

---

## Key Takeaways

1. **Containers** = app + dependencies bundled together; lightweight, fast, portable.
2. Containers **share the host kernel**. VMs each have their own.
3. Containers stand on three Linux pillars: **namespaces** (isolation), **cgroups** (limits), **union FS** (layered images).
4. Image vs container: image is the blueprint, container is the running instance.
5. Common runtimes: **Docker, containerd, CRI-O, Podman**. Common orchestrators: **Kubernetes, Docker Compose**.
