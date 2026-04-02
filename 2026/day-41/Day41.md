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