
### Task 1: The Problem with Large Images
1. Write a simple Go, Java, or Node.js app (even a "Hello World" is fine)
mkdir node
cd node
touch app.js
alert("hello");
2. Create a Dockerfile that builds and runs it in a **single stage**
Dockerfile
FROM node:18
WORKDIR /app
COPY . .
EXPOSE 8080
CMD["node","app.js"]
3. Build the image and check its **size**
docker build -t node-app .
docker images
image is 1.57GB
Note down the size — you'll compare it later.


## Task 2: Multi-Stage Build
1. Rewrite the Dockerfile using **multi-stage build**:
   - Stage 1: Build the app (install dependencies, compile)
   - Stage 2: Copy only the built artifact into a minimal base image (`alpine`, `distroless`, or `scratch`)
FROM node:20-alpine as Builder
WORKDIR /app
COPY app.js .
CMD ["node", "app.js"]
2. Build the image and check its size again
docker build -t node .
now size becomes 48 mbs only

3. Compare the two sizes

Write in your notes: Why is the multi-stage image so much smaller?
Multi-stage builds reduce image size by separating the build environment
from the runtime environment.

In the first stage, all dependencies, build tools, and source code are used
to build the application.

In the second stage, only the final built artifact is copied into a minimal
base image, excluding unnecessary files like compilers, package managers,
and development dependencies.

This results in a smaller, more secure, and efficient Docker image.


### Task 3: Push to Docker Hub
1. Create a free account on [Docker Hub](https://hub.docker.com) (if you don't have one)
2. Log in from your terminal
docker login
3. Tag your image properly: `yourusername/image-name:tag`
docker tag node:latest sahil260605/node:v1
4. Push it to Docker Hub
docker push sahil260605/node:v1
5. Pull it on a different machine (or after removing locally) to verify
docker pull sahil260605/node:v1


### Task 4: Docker Hub Repository
1. Go to Docker Hub and check your pushed image
2. Add a **description** to the repository
3. Explore the **tags** tab — understand how versioning works
4. Pull a specific tag vs `latest` — what happens?
Tags in Docker Hub represent different versions of an image.
Pulling a specific tag ensures consistency, while 'latest' may change
over time and is not recommended for production use.
---

### Task 5: Image Best Practices
Apply these to one of your images and rebuild:
1. Use a **minimal base image** (alpine vs ubuntu — compare sizes)
2. **Don't run as root** — add a non-root USER in your Dockerfile
3. Combine `RUN` commands to **reduce layers**
4. Use **specific tags** for base images (not `latest`)
Docker image best practices include:

1. Using minimal base images like Alpine to reduce size.
2. Avoid running containers as root for better security.
3. Combining RUN commands to reduce layers.
4. Using specific image tags instead of 'latest' for stability.

These practices improve performance, security, and maintainability.