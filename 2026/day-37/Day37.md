## Quick-Fire Questions
Answer from memory, then verify:
1. What is the difference between an image and a container?
Image = blue print/template
container is the running instance of image
2. What happens to data inside a container when you remove it?
container delete ----> data delete
3. How do two containers on the same custom network communicate?
Same network ---> container name se connect
db:5432
redis:6379
4. What does `docker compose down -v` do differently from `docker compose down`?
docker compose down ----deletes all the container and networks
docker compose down -v ----> deletes all the container network and vloumns that can cause result in loss of all the volume data
5. Why are multi-stage builds useful?
it will remove build tools 
final image becames more secure
6. What is the difference between `COPY` and `ADD`?
7. What does `-p 8080:80` mean?
8080--> host
80---> container
8. How do you check how much disk space Docker is using?
docker system df
---

## Build Your Docker Cheat Sheet
Create `docker-cheatsheet.md` organized by category:
- **Container commands** — run, ps, stop, rm, exec, logs
docker run -d nginx
docker ps 
docker ps -a
docker stop container-name
docker rm container-name
docker exec -it ubuntu bash
docker logs -f container
- **Image commands** — build, pull, push, tag, ls, rm
docker build -t name .
docker pull image-name
docker push username/image-name
docker tag myimage username/myimage
docker images
docker rmi image
- **Volume commands** — create, ls, inspect, rm
docker volume create my-data
docker volume ls
docker volumne inspect my-data
docker volume rm my-data
- **Network commands** — create, ls, inspect, connect
docker network create my-net
docker network ls
docker network inspect my-net
docker network rm my-data
docker network connect my-net container
- **Compose commands** — up, down, ps, logs, build
docker compose up
docker compose down
docker compose ps 
docker compose logs -f
docker compose build
- **Cleanup commands** — prune, system df
docker container prune 
docker image prune -a 
docker system prune -a 
docker system df
- **Dockerfile instructions** — FROM, RUN, COPY, WORKDIR, EXPOSE, CMD, ENTRYPOINT