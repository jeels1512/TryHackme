# Docker Commands Reference

A complete cheat sheet of essential Docker commands. Bookmark this.

## Table of Contents

1. [Container Lifecycle](#container-lifecycle)
2. [Container Information](#container-information)
3. [Images](#images)
4. [Dockerfile & Building](#dockerfile--building)
5. [Volumes](#volumes)
6. [Networks](#networks)
7. [Docker Compose](#docker-compose)
8. [Registry & Hub](#registry--hub)
9. [System & Cleanup](#system--cleanup)
10. [Debugging](#debugging)

---

## Container Lifecycle

```bash
# Run a container
docker run <image>                          # Create and start
docker run -d <image>                       # Detached (background)
docker run -it <image> bash                 # Interactive shell
docker run --name myapp <image>             # Named container
docker run --rm <image>                     # Auto-remove when stopped
docker run -p 8080:80 <image>               # Port mapping
docker run -v mydata:/data <image>          # Volume mount
docker run -e VAR=value <image>             # Environment variable
docker run --restart=always <image>         # Auto-restart policy

# Lifecycle control
docker start <container>                    # Start stopped container
docker stop <container>                     # Graceful stop (10s timeout)
docker kill <container>                     # Force stop immediately
docker restart <container>                  # Restart
docker pause <container>                    # Pause processes
docker unpause <container>                  # Resume processes
docker rm <container>                       # Delete stopped container
docker rm -f <container>                    # Force delete (even if running)
docker rm $(docker ps -aq)                  # Delete ALL containers
```

---

## Container Information

```bash
# Listing
docker ps                                   # Running containers
docker ps -a                                # All containers (including stopped)
docker ps -q                                # Just IDs (useful for scripts)
docker ps -l                                # Last created container
docker ps --filter "status=exited"          # Filter by status

# Inspection
docker inspect <container>                  # Full JSON details
docker logs <container>                     # Print logs
docker logs -f <container>                  # Follow logs (live)
docker logs --tail 100 <container>          # Last 100 lines
docker logs --since 1h <container>          # Last hour
docker top <container>                      # Running processes inside
docker stats                                # Live CPU/memory of all
docker stats <container>                    # Live stats for one
docker port <container>                     # Show port mappings
docker diff <container>                     # Files changed since start
```

---

## Images

```bash
# Listing & inspection
docker images                               # List all images
docker images -a                            # Include intermediate layers
docker images -q                            # Just IDs
docker image inspect <image>                # Full image details
docker history <image>                      # Show image layers
docker history --no-trunc <image>           # Full commands (no truncation)

# Pulling & pushing
docker pull <image>                         # Download from registry
docker pull <image>:<tag>                   # Specific version
docker push <image>:<tag>                   # Upload to registry

# Managing
docker tag <source> <target>                # Create new tag
docker rmi <image>                          # Delete image
docker rmi -f <image>                       # Force delete
docker rmi $(docker images -q)              # Delete ALL images

# Saving & loading (for offline transfer)
docker save -o myimage.tar <image>          # Save image to file
docker load -i myimage.tar                  # Load from file
```

---

## Dockerfile & Building

```bash
# Building
docker build .                              # Build from current dir
docker build -t myapp:v1 .                  # Build with tag
docker build -t myapp:v1 -f Dockerfile.dev .  # Custom Dockerfile name
docker build --no-cache -t myapp .          # Force rebuild from scratch
docker build --build-arg VAR=value .        # Pass build argument
docker build --target stage1 .              # Build only a stage (multi-stage)

# Common Dockerfile instructions
# FROM image:tag           - Base image
# WORKDIR /path            - Set working directory
# COPY src dest            - Copy files in
# ADD src dest             - Like COPY + extracts archives + URLs
# RUN command              - Execute during build
# ENV KEY=value            - Environment variable
# ARG KEY=default          - Build-time variable
# EXPOSE 8080              - Document port (informational)
# VOLUME /data             - Declare volume mount point
# USER username            - Switch user
# CMD ["cmd", "arg"]       - Default command (overridable)
# ENTRYPOINT ["cmd"]       - Always runs (CMD becomes args)
# LABEL key=value          - Metadata
# HEALTHCHECK ...          - Container health check
```

---

## Volumes

```bash
# Creating & managing
docker volume create <name>                 # Create named volume
docker volume ls                            # List volumes
docker volume inspect <name>                # Volume details
docker volume rm <name>                     # Delete volume
docker volume prune                         # Remove unused volumes

# Using volumes (in docker run)
-v <name>:/path/in/container                # Named volume
-v /host/path:/container/path               # Bind mount (host folder)
-v /host/path:/container/path:ro            # Read-only bind mount
--tmpfs /path                               # In-memory volume (RAM)

# Newer syntax (preferred for production)
--mount type=volume,source=<name>,target=/path
--mount type=bind,source=/host/path,target=/path
--mount type=tmpfs,target=/path
```

---

## Networks

```bash
# Managing networks
docker network ls                           # List networks
docker network create <name>                # Create a network
docker network create --driver bridge <name>  # Specify driver
docker network inspect <name>               # Network details
docker network rm <name>                    # Delete network
docker network prune                        # Remove unused networks

# Connecting containers
docker run --network <name> <image>         # Run in network
docker network connect <network> <container>   # Connect existing
docker network disconnect <network> <container>  # Disconnect

# Network types
# bridge   - Default, isolated network on host
# host     - Share host's network (no isolation)
# none     - No networking
# overlay  - Multi-host (Docker Swarm)
```

---

## Docker Compose

```bash
# Basic operations
docker-compose up                           # Start all services
docker-compose up -d                        # Detached (background)
docker-compose up --build                   # Rebuild images first
docker-compose down                         # Stop and remove
docker-compose down -v                      # Also delete volumes
docker-compose stop                         # Stop without removing
docker-compose start                        # Start stopped services
docker-compose restart                      # Restart all

# Information
docker-compose ps                           # List services
docker-compose logs                         # All service logs
docker-compose logs -f                      # Follow logs
docker-compose logs <service>               # Specific service logs
docker-compose top                          # Running processes

# Building & running
docker-compose build                        # Build/rebuild services
docker-compose build --no-cache             # Force rebuild
docker-compose pull                         # Pull latest images
docker-compose run <service> <cmd>          # Run one-off command
docker-compose exec <service> bash          # Shell into running service

# Scaling
docker-compose up --scale web=3             # Run 3 instances of 'web'

# Custom compose file
docker-compose -f custom.yml up
docker-compose -f base.yml -f override.yml up
```

---

## Registry & Hub

```bash
# Authentication
docker login                                # Log in to Docker Hub
docker login registry.example.com           # Log in to private registry
docker logout                               # Log out

# Tagging for push
docker tag local-image username/repo:tag
docker tag myapp registry.example.com/myapp:v1

# Pushing & pulling
docker push username/repo:tag
docker pull username/repo:tag

# Searching (Docker Hub only)
docker search nginx                         # Search for images
docker search --limit 5 nginx               # Limit results
```

---

## System & Cleanup

```bash
# Information
docker version                              # Client + server versions
docker info                                 # System-wide info
docker system df                            # Disk usage
docker system df -v                         # Detailed disk usage
docker system events                        # Real-time events

# Cleanup
docker system prune                         # Remove stopped containers, unused networks, dangling images
docker system prune -a                      # Also remove all unused images
docker system prune -a --volumes            # Nuclear: also volumes

# Targeted cleanup
docker container prune                      # Remove stopped containers
docker image prune                          # Remove dangling images
docker image prune -a                       # Remove all unused images
docker volume prune                         # Remove unused volumes
docker network prune                        # Remove unused networks
docker builder prune                        # Remove build cache
```

---

## Debugging

```bash
# Shell access
docker exec -it <container> bash            # Bash shell (Debian/Ubuntu)
docker exec -it <container> sh              # Sh shell (Alpine)
docker exec -it <container> <command>       # Run any command
docker exec -u root -it <container> bash    # As root user

# When container won't start
docker logs <container>                     # Check for errors
docker inspect <container>                  # Check config
docker events                               # See what's happening

# When container exits immediately
docker run -it <image> sh                   # Override entrypoint with shell
docker run --entrypoint sh -it <image>      # Force shell entrypoint

# Copy files in/out
docker cp file.txt <container>:/path/       # Copy to container
docker cp <container>:/path/file.txt .      # Copy from container

# Check resource usage
docker stats <container>                    # Live stats
docker top <container>                      # Processes

# Update running container (limited)
docker update --memory 512m <container>     # Change memory limit
docker update --cpus 0.5 <container>        # Change CPU limit
docker rename old-name new-name             # Rename
```

---

## Security Commands (DevSecOps Bonus)

```bash
# Scanning (requires Trivy installed)
trivy image <image>                         # Vulnerability scan
trivy image --severity HIGH,CRITICAL <image>   # Only severe issues
trivy image --format json <image>           # JSON output

# Docker Scout (built-in to Docker Desktop)
docker scout cves <image>                   # List CVEs
docker scout quickview <image>              # Summary
docker scout recommendations <image>        # How to fix

# Dockerfile linting (requires Hadolint)
hadolint Dockerfile

# Running with reduced privileges
docker run --read-only <image>              # Read-only filesystem
docker run --cap-drop=ALL <image>           # Drop all capabilities
docker run --cap-add=NET_BIND_SERVICE <image>  # Add specific capability
docker run --security-opt=no-new-privileges <image>  # Prevent privilege escalation
docker run --user 1000:1000 <image>         # Run as specific user
docker run --memory=256m --cpus=0.5 <image>   # Resource limits

# Content trust (image signing)
export DOCKER_CONTENT_TRUST=1               # Require signed images
docker trust sign <image>                   # Sign an image
docker trust inspect <image>                # See signatures
```

---

## Common Flags Reference

| Flag | Meaning | Example |
|------|---------|---------|
| `-d` | Detached (background) | `docker run -d nginx` |
| `-it` | Interactive + TTY | `docker run -it ubuntu bash` |
| `-p` | Port mapping (host:container) | `-p 8080:80` |
| `-v` | Volume mount | `-v data:/app/data` |
| `-e` | Environment variable | `-e DB_HOST=localhost` |
| `--name` | Container name | `--name myapp` |
| `--rm` | Auto-remove when stopped | `--rm` |
| `--network` | Connect to network | `--network mynet` |
| `--restart` | Restart policy | `--restart=always` |
| `-w` | Working directory | `-w /app` |
| `-u` | User | `-u 1000` |
| `--memory` | Memory limit | `--memory=512m` |
| `--cpus` | CPU limit | `--cpus=1.5` |
| `-f` | Force or file | `docker rm -f`, `-f Dockerfile.dev` |
| `-q` | Quiet (IDs only) | `docker ps -q` |
| `-a` | All | `docker ps -a` |

---

## Quick Patterns You'll Use Daily

```bash
# Stop and remove all containers
docker rm -f $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Find a container's IP
docker inspect <container> | grep IPAddress

# See what ports a container exposes
docker port <container>

# Watch logs while developing
docker logs -f <container>

# Quickly test something in a throwaway container
docker run --rm -it alpine sh

# Run a one-off command and clean up
docker run --rm alpine echo "hello"

# Copy a config file into a running container
docker cp myconfig.conf <container>:/etc/app/

# Shell into an Alpine-based container (no bash)
docker exec -it <container> sh

# Restart and follow logs
docker restart <container> && docker logs -f <container>
```

---

## Tips for Memorization

1. **Run `docker --help`** anytime — built-in cheat sheet
2. **Run `docker <command> --help`** for specific command help
3. **The pattern is consistent:** `docker <object> <action>` (e.g., `docker container ls`, `docker image rm`)
4. **Shortcuts exist:** `docker ps` is short for `docker container ls`, `docker images` for `docker image ls`
5. **Tab completion** — install Docker's bash/zsh completion for faster typing

---

## Resources

1. Official docs: https://docs.docker.com
2. Dockerfile reference: https://docs.docker.com/engine/reference/builder/
3. Compose file reference: https://docs.docker.com/compose/compose-file/
4. Play with Docker (browser playground): https://labs.play-with-docker.com
