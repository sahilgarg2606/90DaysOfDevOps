### Task 1: The Problem
1. Run a Postgres or MySQL container
docker run --name=mysql-docker -e MYSQL_ROOT_PASSWORD=test123 -d mysql ----> this command will run the container that container name will be mysql-docker set by tag name --name 
we have set the environments variable -e --d detached mode and then we are going to provide the image name that is MySQL
now after successfully running the container we have to go inside the container with docker exec

2. Create some data inside it (a table, a few rows — anything)
docker exec -it <container_id> bash
mysql -u root -p
enter your password that is being set with help of environment variables
3. Stop and remove the container
docker stop <container_id>  // stop the container 
docker rm <container_id> // removing the container after stopping


4. Run a new one — is your data still there?
after stoping and removing the container and then i have created the new sql container but data is not there like SahilDB i have maded the 
SahilDB 
Write what happened and why.
Docker containers are Ephemeral in nature means temporary


### Task 2: Named Volumes
1. Create a named volume
docker volume create mysql-data
2. Run the same database container, but this time **attach the volume** to it
docker run --name=mysqll -v mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=test123 -d mysql
in this container i have successfully attached the volume by verfiying it with docker inspect container_name in mounts json format 

3. Add some data, stop and remove the container
docker exec -it container-id 
mysql -u root -p test123
SHOW DATABASES;
CREATE DATABASES Student;
USE Student;
CREATE TABLE users (
id INT,
name VARCHAR(50)
);
docker stop container-id && docker rm container-id
4. Run a brand new container with the **same volume**
docker run --name=mysqllll -v mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=test123 -d mysql
5. Is the data still there?
Yes my data is successfully saving even after deleting whole the controller just i have to bind that properly 



### Task 3: Bind Mounts
1. Create a folder on your host machine with an `index.html` file
2. Run an Nginx container and **bind mount** your folder to the Nginx web directory
docker run -d -v D:/nginx:/usr/share/nginx/html -p 80:80 nginx
3. Access the page in your browser
4. Edit the `index.html` on your host — refresh the browser

Write in your notes: What is the difference between a named volume and a bind mount?
Named Volume vs Bind Mount
Feature	Named Volume	Bind Mount
Location	Docker manage karta hai	Host path
Control	Less control	Full control
Use case	Database storage	Development
Performance	Optimized	Depends on host
Path	Hidden (/var/lib/docker)	Visible




### Task 4: Docker Networking Basics
1. List all Docker networks on your machine
docker network ls
2. Inspect the default `bridge` network
docker network inspect ec16cb17b82f
3. Run two containers on the default bridge — can they ping each other by **name**?
docker run -dit --name c1 ubuntu
docker run -dit --name c2 ubuntu
docker exec -it c1 bash
apt update && apt install iputils-ping -y
ping c2 
result will be Name or Service not known
default bridge doesnot support name resolution
4. Run two containers on the default bridge — can they ping each other by **IP**?
docker run -d -v D:/nginx:/usr/share/nginx/html/ -p 80:80 nginx
docker inspect nginx
find for ipAddress 
ping <ip-address>

ping success




### Task 5: Custom Networks
1. Create a custom bridge network called `my-app-net`
docker network create my-app-net
docker network ls
2. Run two containers on `my-app-net`
docker run -d --network=my-app-net -e MYSQL_ROOT_PASSWORD=test mysql
docker run -itd --network=my-app-net ubuntu bash
docker exec -it 6f bash
apt-get update
apt install iputils-ping -y

3. Can they ping each other by **name** now?
Yes now they can ping on custom network
ping container-name
sucessfully pinging from container one to second
4. Write in your notes: Why does custom networking allow name-based communication but the default bridge doesn't?



### Task 6: Put It Together
1. Create a custom network
docker network create custom-net
2. Run a **database container** (MySQL/Postgres) on that network with a volume for data
docker run -d --name=myapp -v mysql-data:/var/lib/mysql --network=custom-net -e MYSQL_ROOT_PASSWORD=test
mysql

3. Run an **app container** (use any image) on the same network
docker run -it -p --name=myapp --network=custom-net nginx
4. Verify the app container can reach the database by container name
docker exec container1
ping container2