# Intro to Docker

> **Room:** [https://tryhackme.com/room/introtodockerk8pdqk](https://tryhackme.com/room/introtodockerk8pdqk)
> **Module:** 4 — Container Security
> **Difficulty:** Easy

## Overview

Hands-on intro to Docker — its architecture, the CLI, building images with Dockerfiles, running containers, networking, volumes, and Docker Compose. By the end you can build, run, and orchestrate containerised apps.

---

## Key Concepts

### Docker architecture

```
┌─────────────────────────────────────────────────────┐
│                  Docker Client (CLI)                 │
│                  docker run / build / ps             │
└──────────────────────┬───────────────────────────────┘
                       │ REST API
┌──────────────────────▼───────────────────────────────┐
│                Docker Daemon (dockerd)               │
│  - Builds images                                     │
│  - Runs containers                                   │
│  - Manages networks, volumes                         │
└──────┬─────────────────────┬─────────────────────────┘
       │                     │
┌──────▼─────┐         ┌─────▼──────┐
│ containerd │         │  Registry  │
│ (runtime)  │         │ (Docker Hub│
│            │         │  GHCR, etc)│
└────────────┘         └────────────┘
```

- **Docker Client** — the `docker` CLI
- **Docker Daemon** — the background service that does the work
- **containerd** — the actual container runtime
- **Registry** — where images are stored (Docker Hub by default)

### Images, containers, and layers

- **Image** — read-only template
- **Container** — running instance with a writeable layer on top
- **Layer** — each `RUN`, `COPY`, `ADD` in a Dockerfile creates a new layer

Layers are cached, so rebuilding only re-runs the changed steps.

### Dockerfile

A text file with instructions for building an image.

```dockerfile
# Use an official base image
FROM node:18-alpine

# Set working directory inside container
WORKDIR /app

# Copy package files first (for layer caching)
COPY package*.json ./

# Install deps
RUN npm install --production

# Copy app source
COPY . .

# Expose port (documentation; doesn't actually open it)
EXPOSE 3000

# Default command when container starts
CMD ["node", "server.js"]
```

### Common Dockerfile instructions

| Instruction | What it does |
|-------------|--------------|
| `FROM` | Base image to start from |
| `WORKDIR` | Set working directory |
| `COPY` | Copy files from host into image |
| `ADD` | Like COPY but also handles URLs and tar archives |
| `RUN` | Execute a command at build time |
| `CMD` | Default command at runtime (overridable) |
| `ENTRYPOINT` | Always-runs command at runtime |
| `ENV` | Set environment variable |
| `EXPOSE` | Document a port (doesn't publish) |
| `VOLUME` | Declare a mount point |
| `USER` | Switch user (great for non-root) |
| `ARG` | Build-time variable |
| `LABEL` | Add metadata |

### CMD vs ENTRYPOINT

- `CMD` — easily overridden (`docker run image other-command`)
- `ENTRYPOINT` — always runs; CMD becomes its arguments

Common pattern:
```dockerfile
ENTRYPOINT ["python", "app.py"]
CMD ["--port", "8080"]
```

### Docker networking

| Network type | Notes |
|--------------|-------|
| `bridge` | Default. Each container gets an IP on a virtual bridge. |
| `host` | Container shares the host's network. No isolation. |
| `none` | No network. |
| `overlay` | Multi-host networks (used by Swarm/K8s) |
| Custom bridge | Containers on it can resolve each other by name |

### Volumes & bind mounts

- **Volume** — managed by Docker, persists across container restarts
- **Bind mount** — mounts a host directory into the container
- **tmpfs** — in-memory only

```bash
# Volume
docker run -v mydata:/app/data myimage

# Bind mount
docker run -v $(pwd)/data:/app/data myimage

# tmpfs
docker run --tmpfs /tmp myimage
```

### Docker Compose

For running **multiple** containers together. Defined in `docker-compose.yml`:

```yaml
services:
  web:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - db
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: example
    volumes:
      - dbdata:/var/lib/postgresql/data
volumes:
  dbdata:
```

Then:
```bash
docker compose up -d
```

### Docker security basics

(Covered deeper in the Container Hardening room, but worth knowing now)

- Don't run as root inside the container — use `USER`
- Don't use `latest` tag — pin to a specific version
- Don't put secrets in Dockerfiles or images
- Keep images small (use `alpine` or `distroless` base images)
- Multi-stage builds to leave build tools out of the final image

---

## Commands Cheatsheet

### Image management

```bash
# Pull an image
docker pull nginx:1.25.4
docker pull python:3.12-slim

# List images
docker images
docker image ls

# Remove image
docker rmi nginx:1.25.4
docker image rm <image-id>

# Remove dangling images
docker image prune

# Remove all unused images
docker image prune -a

# Build an image
docker build -t myapp:1.0 .
docker build -t myapp:1.0 -f Dockerfile.prod .

# Build with arg
docker build --build-arg VERSION=1.2 -t myapp:1.0 .

# Tag an image
docker tag myapp:1.0 registry.example.com/myapp:1.0

# Push to registry
docker push registry.example.com/myapp:1.0

# History (see layers)
docker history nginx
```

### Container lifecycle

```bash
# Run a container
docker run nginx
docker run -d nginx                        # detached
docker run -d -p 8080:80 nginx             # port mapping host:container
docker run -d --name web nginx             # name it
docker run -it ubuntu bash                 # interactive shell
docker run --rm -it ubuntu bash            # auto-remove on exit

# List running
docker ps

# List all (including stopped)
docker ps -a

# Stop / start / restart
docker stop <name|id>
docker start <name|id>
docker restart <name|id>

# Remove
docker rm <name|id>
docker rm -f <name|id>                     # force-remove a running container

# Remove all stopped
docker container prune

# Logs
docker logs <name|id>
docker logs -f <name|id>                   # follow
docker logs --tail 50 <name|id>

# Exec into a running container
docker exec -it <name|id> bash
docker exec -it <name|id> sh               # alpine images don't have bash

# Inspect
docker inspect <name|id>
docker stats                               # live resource use
```

### Volumes

```bash
docker volume ls
docker volume create mydata
docker volume inspect mydata
docker volume rm mydata
docker volume prune
```

### Networks

```bash
docker network ls
docker network create mynet
docker network inspect bridge
docker network connect mynet <container>
docker network disconnect mynet <container>
docker network rm mynet

# Run on a specific network
docker run --network mynet nginx
```

### Docker Compose

```bash
docker compose up                          # foreground
docker compose up -d                       # detached
docker compose down                        # stop and remove
docker compose down -v                     # also remove volumes
docker compose ps
docker compose logs
docker compose logs -f web
docker compose exec web bash
docker compose build
docker compose pull
docker compose restart
```

### System

```bash
docker info
docker version
docker system df                           # disk usage
docker system prune                        # remove all unused stuff
docker system prune -a --volumes           # nuclear option
```

### Security helpers

```bash
# See what user a container runs as
docker exec <c> whoami
docker exec <c> id

# Inspect a container's privileges
docker inspect --format '{{.HostConfig.Privileged}}' <c>

# Inspect capabilities
docker inspect --format '{{.HostConfig.CapAdd}}' <c>
docker inspect --format '{{.HostConfig.CapDrop}}' <c>
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — Docker architecture**
- Q: What component receives commands from the Docker CLI?
- A: `Docker daemon` (or `dockerd`)
- Q: What's the underlying runtime Docker uses?
- A: `containerd`

**Task 3 — Images vs containers**
- Q: A running instance of an image is called?
- A: `container`
- Q: A read-only template is?
- A: `image`

**Task 4 — Dockerfile**
- Q: What instruction sets the base image?
- A: `FROM`
- Q: What instruction copies files into the image?
- A: `COPY`
- Q: What instruction runs a command at build time?
- A: `RUN`
- Q: What instruction sets the default command at runtime?
- A: `CMD`

**Task 5 — Practical: Run a container**
- Pull and run nginx:
```bash
docker pull nginx
docker run -d -p 80:80 --name web nginx
```
- Visit `http://<machine-ip>` to see it work.

**Task 6 — Practical: Build your own image**
- Create a `Dockerfile`:
```dockerfile
FROM python:3.12-alpine
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
```
- Build and run:
```bash
docker build -t myapp .
docker run --rm myapp
```
- The flag is usually printed by the running container or found inside it.

**Task 7 — Volumes**
- Q: Which mount type is fully managed by Docker?
- A: `volume`
- Q: Which mount type uses a path on the host?
- A: `bind mount`

**Task 8 — Docker Compose**
- Q: What's the file used to define a multi-container app?
- A: `docker-compose.yml`
- Q: Command to start a Compose stack in the background?
- A: `docker compose up -d`

**Task 9 — Conclusion**
- Click to complete.

---

## Key Takeaways

1. **Docker = client + daemon + runtime + registry.** CLI talks to daemon, daemon uses containerd to run containers.
2. **Dockerfile** instructions are layered — order matters for caching.
3. **`CMD` vs `ENTRYPOINT`** — CMD is overrideable, ENTRYPOINT is locked in.
4. **Volumes** for persistence; **bind mounts** for live host folders.
5. **Docker Compose** orchestrates multi-container apps with a single YAML file.
