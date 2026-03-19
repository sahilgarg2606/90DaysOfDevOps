### Task 1: Your First Dockerfile
1. Create a folder called `my-first-image`
mkdir my-first-image
2. Inside it, create a `Dockerfile` that:
   - Uses `ubuntu` as the base image
   - Installs `curl`
   - Sets a default command to print `"Hello from my custom image!"`

-------------------Docker file-----------------
FROM ubuntu

WORKDIR /app

COPY . .

RUN apt-get update && apt install curl

RUN chmod +x hello.sh

CMD ["sh","hello.sh"]
3. Build the image and tag it `my-ubuntu:v1`
docker build -t my-ubuntu:v1 .
4. Run a container from your image
docker run -itd my-ubuntu:v1 bash


### Task 2: Dockerfile Instructions
Create a new Dockerfile that uses **all** of these instructions:
- `FROM` — base image
- `RUN` — execute commands during build
- `COPY` — copy files from host to image
- `WORKDIR` — set working directory
- `EXPOSE` — document the port
- `CMD` — default command
FROM python:3.14

WORKDIR /app

COPY . .

RUN  pip install --upgrade pip && pip install -r requirements.txt

EXPOSE 8000

CMD ["python" ,"main.py"]
Build and run it. Understand what each line does.




### Task 3: CMD vs ENTRYPOINT
1. Create an image with `CMD ["echo", "hello"]` — run it, then run it with a custom command. What happens?
From alpine
CMD ["echo" , "hello"]
docker run myimage 
output will be hello
docker run myimage hi
output will be hi as you can see it CMD override its command 
2. Create an image with `ENTRYPOINT ["echo"]` — run it, then run it with additional arguments. What happens?
from alpine
ENTRYPOINT ["echo"]
docker run myimage
output --> (empty)
docker run myimage hello
output --> hello

3. Write in your notes: When would you use CMD vs ENTRYPOINT?
in the cmd arguments will be override 
but in the entry point arguments are appended



### Task 4: Build a Simple Web App Image
1. Create a small static HTML file (`index.html`) with any content
i have added the content in index.html
2. Write a Dockerfile that:
   - Uses `nginx:alpine` as base
   - Copies your `index.html` to the Nginx web directory

--------------Docker file-----------------------------
FROM nginx

WORKDIR /app

COPY index.html /usr/share/nginx/html

EXPOSE 80
3. Build and tag it `my-website:v1`
docker build -t my-website:v1 .

4. Run it with port mapping and access it in your browser
docker run -d -p 80:80 <container-id>