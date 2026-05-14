### Docker

**Docker Commands**

docker ps               # See running containers

docker ps -a            # See ALL containers (including stopped)

docker stop gitea       # Stop a container

docker start gitea      # Start it again

docker rm gitea         # Delete it (must be stopped first)

docker logs gitea       # See what the container is printing

docker exec -it gitea bash   # Go INTO the container's shell
