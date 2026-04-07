
### Task 1: Multi-Job Workflow
Create `.github/workflows/multi-job.yml` with 3 jobs:
- `build` — prints "Building the app"
- `test` — prints "Running tests"
- `deploy` — prints "Deploying"

Make `test` run only **after** `build` succeeds.
Make `deploy` run only **after** `test` succeeds.
jobs:
    build:
        runs-on: ubuntu-latest
        steps:
            - name: Build
              run: echo "Building the App"
    test:
        runs-on: ubuntu-latest
        needs: 
            - build
        steps:
            - name: testing 
              run: echo "Running tests"
    deploy:
        runs-on: ubuntu-latest
        needs: 
            - build
            - test
        steps:
            - name: Deploy
              run: echo "Deploying"


**Verify:** Check the workflow graph in the Actions tab — does it show the dependency chain?
yes it show the dependency chain because we have added the dependency if build properly executes then only test run



---

### Task 2: Environment Variables
In a new workflow, use environment variables at 3 levels:
1. **Workflow level** — `APP_NAME: myapp`
2. **Job level** — `ENVIRONMENT: staging`
3. **Step level** — `VERSION: 1.0.0`

Print all three in a single step and verify each is accessible.

Then use a **GitHub context variable** — print the commit SHA and the actor (who triggered the run).
name: environment practices
env:
    APP_NAME: myApp

on: 
    push:
        branches:
            - master
jobs:
   build:
    runs-on: ubuntu-latest
    env: 
        name: staging
    steps: 
      - name: version 1
        env:
            version: "1.0.0"
        run: |
         echo ${APP_NAME}
         echo ${name}
         echo ${version}
         echo ${{ github.actor }}
         echo ${{ github.sha }}

### Task 3: Job Outputs
1. Create a job that **sets an output** — e.g., today's date as a string
2. Create a second job that **reads that output** and prints it
3. Pass the value using `outputs:` and `needs.<job>.outputs.<name>`

Write in your notes: Why would you pass outputs between jobs?
name: outputs
on:
    push:
        branches:
            - master

jobs:
   generate-date:
      runs-on: ubuntu
      outputs:
        date: ${{steps.set-date.outputs.date}}
 
      steps:

        - name: Generate the date
          id: set-date
          run:  echo "date=$(date +'%Y-%m-%d')" >> $GITHUB_OUTPUT

   set-date:
        needs: 
            - generate-date
        runs-on: ubuntu-latest
        steps:
            - name: get the date
              run: echo "previos job output is ${{needs.generate-date.outputs.date}}"
        

### Task 4: Conditionals
In a workflow, add:
1. A step that only runs when the branch is `main`
2. A step that only runs when the previous step **failed**
3. A job that only runs on **push** events, not on pull requests
4. A step with `continue-on-error: true` — what does this do?
if one pipeline fail it will still executes it further

name: conditionals
on: [push]

jobs:
    for-main:
        runs-on: ubuntu-latest
        steps:
            - name: this is for master
              id: step1
              if: github.ref ==  'refs/heads/master'
              run: echo "this is for master branch"

            - name: steps failed
              if: steps.step1.outcome != 'success'
              run: echo "previous code not worked"

            - name: exit 1
              run: exit 1
              continue-on-error: false

            - name: testing
              run: echo "testing passed"
    push-event:
        runs-on: ubuntu-latest
        if: github.event_name == 'push'
        steps:
            - name: this is for push
              run: echo "push event triggered"
### Task 5: Putting It Together
Create `.github/workflows/smart-pipeline.yml` that:
1. Triggers on push to any branch
2. Has a `lint` job and a `test` job running in parallel
3. Has a `summary` job that runs after both, prints whether it's a `main` branch push or a feature branch push, and prints the commit message

jobs:
    linting:
        runs-on: ubuntu-latest
        steps:
            - name: linting
              run: echo "linting completed"
    test:
        runs-on: ubuntu-latest
        steps:
            - name: testing
              run: echo "testing"
    summary:
        needs: [linting, test]
        runs-on: ubuntu-latest
        steps:
            - name: summary
              run:  |
                    echo "code is pushed from ${{ github.ref_name }}"
                    echo "code commit message ${{ github.event.commits[0].message }}"