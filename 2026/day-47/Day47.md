### Task 1: Pull Request Event Types
Create `.github/workflows/pr-lifecycle.yml` that triggers on `pull_request` with **specific activity types**:
1. Trigger on: `opened`, `synchronize`, `reopened`, `closed`
2. Add steps that:
   - Print which event type fired: `${{ github.event.action }}`
   - Print the PR title: `${{ github.event.pull_request.title }}`
   - Print the PR author: `${{ github.event.pull_request.user.login }}`
   - Print the source branch and target branch
3. Add a conditional step that only runs when the PR is **merged** (closed + merged = true)

Test it: create a PR, push an update to it, then merge it. Watch the workflow fire each time with a different event type.
name: pull request lifecycle

on:
    pull_request:
        types: [opened , reopened, synchronize , closed]
        branches:
            - main
jobs:
    events:
        runs-on: ubuntu-latest
        steps:
            - name: event fired , pr title , pr author 
              run: |
                 echo "${{ github.event.action }}"
                 echo "${{ github.event.pull_request.title }}"
                 echo "${{ github.event.pull_request.user.login }}"

            - name: pr merge or not
              if: ${{ github.event.pull_request.merged == true }}
              run: |
                  echo "Bai pr merge hogi aa"



### Task 2: PR Validation Workflow
Create `.github/workflows/pr-checks.yml` — a real-world PR gate:
1. Trigger on `pull_request` to `main`
2. Add a job `file-size-check` that:
   - Checks out the code
   - Fails if any file in the PR is larger than 1 MB
3. Add a job `branch-name-check` that:
   - Reads the branch name from `${{ github.head_ref }}`
   - Fails if it doesn't follow the pattern `feature/*`, `fix/*`, or `docs/*`
4. Add a job `pr-body-check` that:
   - Reads the PR body: `${{ github.event.pull_request.body }}`
   - Warns (but doesn't fail) if the PR description is empty

**Verify:** Open a PR from a badly named branch — does the check fail?
yes it fails for badly named pr 
name: pr-checks

on:
    pull_request:
        types: [opened , synchronize , reopened , closed]
        branches:
            - master

jobs:
    file-size-check:
        runs-on: ubuntu-latest
        steps:
            - name: checkout code
              uses: actions/checkout@v4
            
            - name: Check file sizes in PR
              run: |
                 echo "Checking files larger than 1 MB..."
                  git fetch origin ${{ github.base_ref }}
                  FILES=$(git diff --name-only --diff-filter=AM origin/${{ github.base_ref }})
                   LIMIT=$((1024 * 1024)) # 1 MB
                   FAIL=0

                 for file in $FILES; do
                    if [ -f "$file" ]; then
                    SIZE=$(stat -c%s "$file")
                    echo "$file => $SIZE bytes"

                    if [ "$SIZE" -gt "$LIMIT" ]; then
                        echo "❌ $file exceeds 1 MB limit"
                        FAIL=1
                    fi
                    fi
                 done

                 if [ "$FAIL" -eq 1 ]; then
                    echo "🚨 File size check failed"
                    exit 1
                 else
                    echo "✅ All files are within limit"
                 fi
    branch-name-check:
        runs-on: ubuntu-latest
        env:
            branch: ${{ github.ref_name }}
        steps:
            - name: check pattern
              run: |
                BRANCH_NAME=${{ github.head_ref  }}
                echo "checking pattern: $BRANCH_NAME"
                if [[ "$BRANCH_NAME" =~ ^(feature|fix|tester)/.+$ ]]; then
                    echo "branch name valid"
                else
                    echo "not valid branch"
                   
                fi
    pr-body-check:
        runs-on: ubuntu-latest
        steps:
            - name: pr body checkout
              run: |
                PR_BODY="${{ github.event.pull_request.body }}"
                echo "checking"
                if [ -z "$PR_BODY" == "null"]; then
                   echo "warning : pr empty is empty"
                else 
                   echo "pr descripting is present"
                fi


### Task 3: Scheduled Workflows (Cron Deep Dive)
Create `.github/workflows/scheduled-tasks.yml`:
1. Add a `schedule` trigger with cron: `'30 2 * * 1'` (every Monday at 2:30 AM UTC)
2. Add **another** cron entry: `'0 */6 * * *'` (every 6 hours)
3. In the job, print which schedule triggered using `${{ github.event.schedule }}`
4. Add a step that acts as a **health check** — curl a URL and check the response code

Write in your notes:
- The cron expression for: every weekday at 9 AM IST
30 3 * * 1-5
- The cron expression for: first day of every month at midnight
0 0 1 * *
- Why GitHub says scheduled workflows may be delayed or skipped on inactive repos
GitHub warns about this because:

⏳ Not real-time guarantees → Cron jobs can be delayed due to load
💤 Inactive repositories:
If no activity for a while (like ~60 days), schedules may be disabled
🚦 Queue & capacity limits:
GitHub Actions runners are shared → delays can happen
🔄 Best-effort execution:
GitHub does NOT guarantee exact timing like a dedicated cron server
**Important:** Also add `workflow_dispatch` so you can test it manually without waiting for the schedule.

name: Scheduled Tasks

on:
  schedule:
    # Every Monday at 2:30 AM UTC
    - cron: '30 2 * * 1'

    # Every 6 hours
    - cron: '0 */6 * * *'

  # Allow manual trigger
  workflow_dispatch:

jobs:
  scheduled-job:
    runs-on: ubuntu-latest

    steps:
      - name: Print triggering schedule
        run: |
          echo "Workflow triggered by schedule: ${{ github.event.schedule }}"

      - name: Health check (curl)
        run: |
          URL="https://example.com"

          echo "Checking health of $URL"

          STATUS=$(curl -o /dev/null -s -w "%{http_code}" $URL)

          echo "HTTP Status: $STATUS"

          if [ "$STATUS" -ne 200 ]; then
            echo "❌ Health check failed!"
            exit 1
          else
            echo "✅ Health check passed!"
          fi


### Task 4: Path & Branch Filters
Create `.github/workflows/smart-triggers.yml`:
1. Trigger on push but **only** when files in `src/` or `app/` change:
   ```yaml
   on:
     push:
       paths:
         - 'src/**'
         - 'app/**'
   ```
2. Add `paths-ignore` in a second workflow that skips runs when only docs change:
   ```yaml
   paths-ignore:
     - '*.md'
     - 'docs/**'
   ```
3. Add branch filters to only trigger on `main` and `release/*` branches
4. Test it: push a change to a `.md` file — does the workflow skip?
name: smart triggers

on:
  push:
    branches:
        - main
        - 'release/*'
    paths:
      - 'src/**'
      - 'app/**'
    paths-ignore:
      - '*.md'
      - 'docs/**'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run job
        run: echo "✅ Non-doc changes detected"
Write in your notes: When would you use `paths` vs `paths-ignore`?


### Task 5: `workflow_run` — Chain Workflows Together
Create two workflows:
1. `.github/workflows/tests.yml` — runs tests on every push
2. `.github/workflows/deploy-after-tests.yml` — triggers **only after** `tests.yml` completes successfully:
   ```yaml
   on:
     workflow_run:
       workflows: ["Run Tests"]
       types: [completed]
   ```
3. In the deploy workflow, add a conditional:
   - Only proceed if the triggering workflow **succeeded** (`${{ github.event.workflow_run.conclusion == 'success' }}`)
   - Print a warning and exit if it failed

**Verify:** Push a commit — does the test workflow run first, then trigger the deploy workflow?
yes test workflow run first then trigger the deploy workflow
---