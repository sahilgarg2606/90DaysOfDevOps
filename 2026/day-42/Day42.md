### Task 1: GitHub-Hosted Runners
1. Create a workflow with 3 jobs, each on a different OS:
   - `ubuntu-latest`
   - `windows-latest`
   - `macos-latest`
2. In each job, print:
   - The OS name
   - The runner's hostname
   - The current user running the job
3. Watch all 3 run in parallel

name: OS informations
on: 
    push:
        branches:
            - master
jobs:
  osInfo:
      strategy:
         fail-fast: false
         matrix:
            os: ["ubuntu-latest" ,"windows-latest","macos-latest"]
      runs-on: ${{ matrix.os }}
      steps:
        - name: name of OS
          id: step1
          run: echo "${{runner.os}}"
        - name: check hostname of Running os
          run: hostname
        - name: current user name
          run: |
             echo "User:"
             whoami
Write in your notes: What is a GitHub-hosted runner? Who manages it?
ans--> github-hosted runner are virtual machines that are provided by the github and it also being managed by them only we do not need to manage it manually


### Task 2: Explore What's Pre-installed
1. On the `ubuntu-latest` runner, run a step that prints:
   - Docker version
   - Python version
   - Node version
   - Git version
name: package checker

on: 
    push:
        branches: 
            - master

jobs:
    packageChecker:
        runs-on: ubuntu-latest
        strategy:
            matrix:
                package: ["docker","git","node","python"]
        steps:
            - name: ${{ matrix.package }} check
              run: ${{matrix.package}} --version


2. Look up the GitHub docs for the full list of pre-installed software on `ubuntu-latest`
https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md
Write in your notes: Why does it matter that runners come with tools pre-installed?
faster continuos integration
no manual installation
consistent environment
cost effieient


### Task 3: Set Up a Self-Hosted Runner
1. Go to your GitHub repo → Settings → Actions → Runners → **New self-hosted runner**
2. Choose Linux as the OS
3. Follow the instructions to download and configure the runner on:
   - Your local machine, OR
   - A cloud VM (EC2, Utho, or any VPS)
   go to aws console signin
   create ec2 server 
   connct that ec2 server with ssh
   paste the following commands

4. Start the runner — verify it shows as **Idle** in GitHub
it shows that idle
**Verify:** Your runner appears in the Runners list with a green dot.

### Task 4: Use Your Self-Hosted Runner
1. Create `.github/workflows/self-hosted.yml`
2. Set `runs-on: self-hosted`
3. Add steps that:
   - Print the hostname of the machine (it should be YOUR machine/VM)
   - Print the working directory
   - Create a file and verify it exists on your machine after the run
4. Trigger it and watch it run on your own hardware
name: self hosting runner

on: 
    workflow_dispatch:
jobs:
    selfhoster:
        runs-on: self-hosted
        steps:
         - name: Host Name
           run: hostname
         
         - name: working directory
           run: pwd
        
         - name: create file 
           run : |
             echo "this is the test file" > file.txt
             echo "file created : file.txt"

         - name: verfiy 
           run: |
             if [ -f "file.txt" ]; then
                echo "file exists"
             else
                echo "doesnot exists"
             fi

        
**Verify:** Check your machine — is the file there?
yes this file will exists



### Task 5: Labels
1. Add a **label** to your self-hosted runner (e.g., `my-linux-runner`)
2. Update your workflow to use `runs-on: [self-hosted, my-linux-runner]`
3. Trigger it — does it still pick up the job?

Write in your notes: Why are labels useful when you have multiple self-hosted runners?

