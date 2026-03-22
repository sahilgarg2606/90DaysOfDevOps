### Task 1: Build Your Own App Stack
Create a `docker-compose.yml` for a 3-service stack:
- A **web app** (use Python Flask, Node.js, or any language you know)
- A **database** (Postgres or MySQL)
- A **cache** (Redis)
-----------docker compose ---------------------
services:
  flask-app:
    build: ./app
    container_name: flask-app
    ports:
      - "5000:5000"
    depends_on:
      db:
       condition: service_healthy
    environment:
      DB_HOST: db
      REDIS_HOST: redis
    networks:
      - app-network
  db:
    image: postgres:13
    container_name: postgres-db
    restart: always
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 5s
      retries: 5
  redis:
    image: redis
    container_name: redis-cache
    networks:
      - app-network
networks:
  app-network:
volumes:
  db_data:
Write a simple Dockerfile for the web app. The app doesn't need to be complex — even a "Hello World" that connects to the database is enough.


### Task 2: depends_on & Healthchecks
1. Add `depends_on` to your compose file so the app starts **after** the database
depends_on sirf container ka start order define krta 
2. Add a **healthcheck** on the database service
healthcheck -----> actual ready check of the container
3. Use `depends_on` with `condition: service_healthy` so the app waits for the database to be truly ready, not just started
depends_on:
      db:
       condition: service_healthy


### Task 3: Restart Policies
1. Add `restart: always` to your database service
container gets crashed --->automatically gets restart
2. Manually kill the database container — does it come back?
3. Try `restart: on-failure` — how is it different?
sirf error pe restart hota hai
4. Write in your notes: When would you use each restart policy?


### Task 4: Custom Dockerfiles in Compose
1. Instead of using a pre-built image for your app, use `build:` in your compose file to build from a Dockerfile
2. Make a code change in your app
3. Rebuild and restart with one command
FROM python:3.8-slim

WORKDIR /app

COPY .  . 

RUN pip install -r requirments.txt

CMD [ "python", "app.py" ]

### Task 5: Named Networks & Volumes
1. Define **explicit networks** in your compose file instead of relying on the default
 networks:
  app-network:
2. Define **named volumes** for database data
volumes:
  db_data:
3. Add **labels** to your services for better organization


### Task 6: Scaling (Bonus)
1. Try scaling your web app to 3 replicas using `docker compose up --scale`
2. What happens? What breaks?
3. Write in your notes: Why doesn't simple scaling work with port mapping?
docker compose up --scale app=3
port 5000 already in use 
Multiple containers → same port map nahi ho sakta