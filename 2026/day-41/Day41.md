### Task 1: Trigger on Pull Request
1. Create `.github/workflows/pr-check.yml`
2. Trigger it only when a pull request is **opened or updated** against `main`
3. Add a step that prints: `PR check running for branch: <branch name>`
4. Create a new branch, push a commit, and open a PR
5. Watch the workflow run automatically
yes when i click on the create pull request then that workflow runs automatically

**Verify:** Does it show up on the PR page?
yes it shows on the pr page
name: pr check
on: 
   pull_request:
      branches: 
        - master
   push:
      branches: 
        - master
jobs:
    pr-check:
        runs-on: ubuntu-latest
        steps:
         - name: checking for pr
           run : echo " PR check running for branch ${{ github.head_ref }} "


### Task 2: Scheduled Trigger
1. Add a `schedule:` trigger to any workflow using cron syntax
2. Set it to run every day at midnight UTC
name: cron scheduler
on: 
  schedule: 
    - cron: "0 0 * * *" // this is for every day at midnight utc
3. Write in your notes: What is the cron expression for every Monday at 9 AM?
cron: "0 9 * * 1"


### Task 3: Manual Trigger
1. Create `.github/workflows/manual.yml` with a `workflow_dispatch:` trigger
2. Add an **input** that asks for an `environment` name (staging/production)
3. Print the input value in a step
4. Go to the **Actions** tab → find the workflow → click **Run workflow**
name: CICD
on: 
  workflow_dispatch:
    inputs:
      environments:
        description: This is the environment for testing only
        default: 'dev'
        required: true
        type: choice
        options:
          - dev
          - prod
**Verify:** Can you trigger it manually and see your input printed?
yes i can trigger it manually and see the input type of dropdown values are devand prod

### Task 4: Matrix Builds
Create `.github/workflows/matrix.yml` that:
1. Uses a matrix strategy to run the same job across:
   - Python versions: `3.10`, `3.11`, `3.12`
2. Each job installs Python and prints the version
3. Watch all 3 run in parallel

Then extend the matrix to also include 2 operating systems — how many total jobs run now?
name: python-linter
on:
  push: 
    branches:
      - main 
jobs:
   validate:
      runs-on: ubuntu-latest
      strategy: 
         fail-fast: false
         matrix:
            python-version: ["3.9","3.10","3.11"]
      steps:
        - name: code checkout
          uses: actions/checkout@v4

        - name: setup python ${{ matrix.python_version }}
          uses: actions/setup-python@v5
          with: 
            python-version: ${{ matrix.python_version}}
        
        - name: install
          run: pip install -r requirements.txt
        
        - name: run linter
          run: flake8 app.py
---

### Task 5: Exclude & Fail-Fast
1. In your matrix, **exclude** one specific combination (e.g., Python 3.10 on Windows)
strategy:
   fail-fast: false
   matrix: 
     os: [ubuntu , windows]
     python-version: ["3.9","3.10","3.11"]

     exclude: 
       - os: windows
         python-version: "3.10"
2. Set `fail-fast: false` — trigger a failure in one job and observe what happens to the rest
if set fail-fast:false if any them was fail others version didnot get interupted it will work 
3. Write in your notes: What does `fail-fast: true` (the default) do vs `false`?
if the fail-fast:true then if any of the version fails then all the version wil be failed