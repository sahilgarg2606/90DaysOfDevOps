
## Challenge Tasks

### Task 1: Plan the Project Structure
Create the complete project layout:

```
ansible-docker-project/
  ansible.cfg
  inventory.ini
  site.yml                          # Master playbook
  group_vars/
    all.yml                         # Common variables
    web/
      vars.yml                      # Nginx variables
      vault.yml                     # Encrypted Docker Hub credentials
  roles/
    common/                         # Shared setup for all servers
      tasks/main.yml
    docker/                         # Docker installation and container management
      tasks/main.yml
      templates/
        docker-compose.yml.j2
      handlers/main.yml
      defaults/main.yml
    nginx/                          # Nginx reverse proxy
      tasks/main.yml
      templates/
        nginx.conf.j2
        app-proxy.conf.j2
      handlers/main.yml
      defaults/main.yml
```

Generate the role skeletons:
```bash
mkdir -p ansible-docker-project/roles
cd ansible-docker-project
ansible-galaxy init roles/common
ansible-galaxy init roles/docker
ansible-galaxy init roles/nginx
```

Set up your `ansible.cfg` and `inventory.ini` using what you built on Day 68.

---