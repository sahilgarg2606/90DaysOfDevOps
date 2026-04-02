### Task 1: Set Up
1. Create a new **public** GitHub repository called `github-actions-practice`
2. Clone it locally
3. Create the folder structure: `.github/workflows/`

---

### Task 2: Hello Workflow
Create `.github/workflows/hello.yml` with a workflow that:
1. Triggers on every `push`
2. Has one job called `greet`
3. Runs on `ubuntu-latest`
4. Has two steps:
   - Step 1: Check out the code using `actions/checkout`
   - Step 2: Print `Hello from GitHub Actions!`

Push it. Go to the **Actions** tab on GitHub and watch it run.

**Verify:** Is it green? Click into the job and read every step.
yes it is working abosultely fine
name: hello
on:
  push:
    branches:
      - main
jobs:
  greets:
    runs-on: ubuntu-latest
    steps:
      - name: checkout the code
        uses: actions/checkout@v4

      - name: merging the code
        run: echo "Hello from github actions"
        
### Task 3: Understand the Anatomy
Look at your workflow file and write in your notes what each key does:
- `on:`  ---> on is the triggering event that triggers the pipeline when somes action occur i have putit will 
when developer pushes its news code then it automxatioly trigger means pipeline will start
- `jobs:` ---. all the jobs that are listed under  stard t 
- `runs-on:` --- it tell the working machine and vm 
- `steps:`  --> steps that are listed under the parents
- `uses:` -----> uses means use the already pre created actions is there and i have fetch the code under the workspace
- `run:` -----> means what will the commmand for runer the 
- `name:` (on a step) -----> name on the step tell the working of
