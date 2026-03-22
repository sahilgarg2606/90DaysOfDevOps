
### Task 1: Install & Verify
1. Check if Docker Compose is available on your machine
docker compose version
sudo apt-get update && apt install docker-compose-v2
2. Verify the version
docker-compose --version

### Task 2: Your First Compose File
1. Create a folder `compose-basics`
mkdir compose-basics
2. Write a `docker-compose.yml` that runs a single **Nginx** container with port mapping
vim docker-compose.yml
services:
   nginx:
      image: nginx
      container_name: first-compose
      ports:
        - "80:80"
3. Start it with `docker compose up`
docker compose up
4. Access it in your browser
localhost:80 webpage is successfully accessing
5. Stop it with `docker compose down`
docker compose down
---

### Task 3: Two-Container Setup
Write a `docker-compose.yml` that runs:
- A **WordPress** container
- A **MySQL** container

They should:
- Be on the same network (Compose does this automatically)
- MySQL should have a named volume for data persistence
- WordPress should connect to MySQL using the service name
  ---------------docker-compose----------------
  services:
  db:
    image: mysql:8.0
    container_name: wordpress-db
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - db_data:/var/lib/mysql
    ports:
      - "3306:3306"
    networks:
      - wp-net
  wordpress:
    image: wordpress:latest
    container_name: wordpress-app
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      - db
    volumes:
      - wp_data:/var/www/html
    networks:
      - wp-net
volumes:
  db_data:
  wp_data:

networks:
  wp-net:
    driver: bridge
   
Start it, access WordPress in your browser, and set it up.

**Verify:** Stop and restart with `docker compose down` and `docker compose up` — is your WordPress data still there?


### Task 4: Compose Commands
Practice and document these:
1. Start services in **detached mode**
docker compose up -d ----> run all the services in detached mode
2. View running services'
docker compose ps ----> viewing all the running containers
3. View **logs** of all services
docker compose logs -----> all services logs will be printed
4. View logs of a **specific** service
docker compose logs nginx ----> view the specific service logs
5. **Stop** services without removing
docker compose stop ----> stop all the running containers
6. **Remove** everything (containers, networks)
docker compose down ---> to remove all the containers
7. **Rebuild** images if you make a change
docker compose up -d --build -----> New build + run


### Task 5: Environment Variables
1. Add environment variables directly in your `docker-compose.yml`
services:
  nginx:
    image: nginx
    container_name: first-compose
    ports:
      - "80:80"
    environment:
      - APP_ENV=production
      - APP_NAME=MyApp

2. Create a `.env` file and reference variables from it in your compose file
APP_ENV=development
APP_NAME=my-docker-app
PORT=8081
3. Verify the variables are being picked up
services:
  nginx:
    image: nginx
    container_name: first-compose
    ports:
      - "${PORT}:80"
    environment:
      - APP_ENV=${APP_ENV}
      - APP_NAME=${APP_NAME}

