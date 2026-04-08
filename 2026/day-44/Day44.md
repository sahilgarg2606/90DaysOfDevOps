
### Task 1: GitHub Secrets
1. Go to your repo → Settings → Secrets and Variables → Actions
2. Create a secret called `MY_SECRET_MESSAGE`
3. Create a workflow that reads it and prints: `The secret is set: true` (never print the actual value)
4. Try to print `${{ secrets.MY_SECRET_MESSAGE }}` directly — what does GitHub show?

Write in your notes: Why should you never print secrets in CI logs?
Imagine this:
Your secret = ATM PIN
Logs = public notebook
If you write your PIN there → anyone can use it 

name: secrets 
on:
    push:
        branches: 
            - master

jobs:
    secret-printer:
        runs-on: ubuntu-latest
        steps:
            - name: secret printer
              run: echo "${{secrets.MY_SECRET_MESSAGE}}"
              env:
                MY_MESSAGE: ${{secrets.MY_SECRET_MESSAGE}} 
            - name: print true if setted
              run: |
                if [ -n "$MY_MESSAGE"]; then
                   echo "secret is set"
                else
                   echo "secret is not set"
                fi


### Task 2: Use Secrets as Environment Variables
1. Pass a secret to a step as an environment variable
2. Use it in a shell command without ever hardcoding it
3. Add `DOCKER_USERNAME` and `DOCKER_TOKEN` as secrets (you'll need these on Day 45)

name: secrets 

on:
    push:
        branches: 
            - master

jobs:
    secret-printer:
        runs-on: ubuntu-latest
        env:
            DOCKER_PASS: ${{secrets.DOCKERHUB_TOKEN}}
            DOCKER_USER: ${{secrets.DOCKERHUB_USER}}
        steps:
            - name: secret checker
             
              run: |
                if [ -n "$DOCKER_PASS" ] && [ -n "$DOCKER_USER"]; then
                   echo "variable are set successfully"
                else
                    echo "not set"
                fi  

### Task 3: Upload Artifacts
1. Create a step that generates a file — e.g., a test report or a log file
2. Use `actions/upload-artifact` to save it
3. After the workflow runs, download the artifact from the Actions tab

**Verify:** Can you see and download it from GitHub?

---

### Task 4: Download Artifacts Between Jobs
1. Job 1: generate a file and upload it as an artifact
2. Job 2: download the artifact from Job 1 and use it (print its contents)

Write in your notes: When would you use artifacts in a real pipeline?

name: artifacts

on: 
    push:
        branches:
            - master

jobs:
    artifactss:
        runs-on: ubuntu-latest
        steps:
            - name: generate report
              run: |
                 echo "hello world" >> file.txt
                 echo "kyaa baat hai" >> file.txt
            - name: upload artifacts
              uses: actions/upload-artifact@v4
              with:
                name: my-artifact
                path: file.txt
    download-artifacts:
        runs-on: ubuntu-latest
        needs: [artifactss]
        steps:
            - name: download report
              uses: actions/download-artifact@v4
              with:
                name: my-artifact
                path: file.txt
            - run: ls -l
### Task 5: Run Real Tests in CI
Take any script from your earlier days (Python or Shell) and run it in CI:
1. Add your script to the `github-actions-practice` repo
2. Write a workflow that:
   - Checks out the code
   - Installs any dependencies needed
   - Runs the script
   - Fails the pipeline if the script exits with a non-zero code
3. Intentionally break the script — verify the pipeline goes red
yes i goes red because docker is  already install and i have exited it with non zero code 

4. Fix it — verify it goes green again
i have fix it then it goes green again
name: cache-demo

on: push

jobs:
    script:
        runs-on: ubuntu-latest
        steps:
            - name: checkout code
              uses: actions/checkout@v4

            - name: install
              run: pip install -r requirements.txt
            
            - name: fails
              run: |
                if command -v docker >/dev/null 2>&1; then
                     echo "Docker is installed"
                     exit 1
                 else
                    echo "Docker is NOT installed"
                    
                 fi

### Task 6: Caching
1. Add `actions/cache` to a workflow that installs dependencies
2. Run it twice — observe the time difference
3. Write in your notes: What is being cached and where is it stored?
name: cache-demo

on: push

jobs:
  cache-job:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Cache node modules
        uses: actions/cache@v4
        with:
          path: ~/.npm
          key: npm-cache-${{ hashFiles('package-lock.json') }}

      - name: Install dependencies
        run: npm install