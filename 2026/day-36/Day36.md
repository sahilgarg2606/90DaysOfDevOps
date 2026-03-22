
### Task 1: Pick Your App
Choose **one** of these (or use your own project):
- A **Python Flask/Django** app with a database
- A **Node.js Express** app with MongoDB
- A **static website** served by Nginx with a backend API
- Any app from your GitHub that doesn't have Docker yet

If you don't have an app, clone a simple open-source one and Dockerize it.

---

### Task 2: Write the Dockerfile
1. Create a Dockerfile for your application
2. Use a **multi-stage build** if applicable
3. Use a **non-root user**
4. Keep the image **small** — use alpine or slim base images
5. Add a `.dockerignore` file

Build and test it locally.

---

### Task 3: Add Docker Compose
Write a `docker-compose.yml` that includes:
1. Your **app** service (built from Dockerfile)
2. A **database** service (Postgres, MySQL, MongoDB — whatever your app needs)
3. **Volumes** for database persistence
4. A **custom network**
5. **Environment variables** for configuration (use `.env` file)
6. **Healthchecks** on the database

Run `docker compose up` and verify everything works together.

---

### Task 4: Ship It
1. Tag your app image
2. Push it to Docker Hub
3. Share the Docker Hub link
4. Write a `README.md` in your project with:
   - What the app does
   - How to run it with Docker Compose
   - Any environment variables needed

---

### Task 5: Test the Whole Flow
1. Remove all local images and containers
2. Pull from Docker Hub and run using only your compose file
3. Does it work fresh? If not — fix it until it does

---
# ---------- Stage 1 : Build the application ----------
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app

COPY . .

RUN mvn clean package -DskipTests


# ---------- Stage 2 : Run the application ----------
FROM eclipse-temurin:21-jdk-jammy

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java -jar app.jar"]



services:
  mysql:
    image: mysql:8.0
    container_name: bankappmysql
    environment:
      MYSQL_ROOT_PASSWORD: test@123
      MYSQL_DATABASE: bankAppDB
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
    healthcheck:
      test: ["CMD","mysqladmin","ping","-h","localhost"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s
    networks:
      - bankapp-net
  ollama:
     image: ollama/ollama
     container_name: ollama
     ports:
      - "11434:11434"
     volumes:
      - ollama-data:/root/ollama
     networks:
      - bankapp-net
  bankapp:
    build: .
    container_name: bankapp
    ports:
      - "8080:8080"
    networks:
      - bankapp-net
    environment:
      MYSQL_HOST: mysql
      MYSQL_PORT: 3306
      MYSQL_DATABASE: bankAppDB
      MYSQL_USER: root
      MYSQL_PASSWORD: test@123
      Ollama_URL: https://ollama:11434
    depends_on:
      mysql:
        condition: service_healthy

volumes:
  mysql-data:
  ollama-data:

networks:
  bankapp-net:
    driver: bridge