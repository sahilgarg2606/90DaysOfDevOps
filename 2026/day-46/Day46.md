### Task 1: Understand `workflow_call`
Before writing any code, research and answer in your notes:
1. What is a **reusable workflow**?
2. What is the `workflow_call` trigger?
3. How is calling a reusable workflow different from using a regular action (`uses:`)?
4. Where must a reusable workflow file live?

1. What is a reusable workflow?

👉 A reusable workflow is a workflow that you write once and use in multiple workflows or repos

🌍 Real-world:

Instead of writing:

build steps
docker steps
deploy steps

again and again ❌

👉 You create one reusable workflow and call it everywhere ✅

🧠 2. What is workflow_call?

👉 It is a trigger that allows a workflow to be called by another workflow

on:
  workflow_call:

👉 Means:

“This workflow will not run on push — it runs only when another workflow calls it”

🧠 3. Difference: reusable workflow vs action (uses:)
Feature	Reusable Workflow	Action (uses:)
Level	Full workflow	Single step
Contains	Jobs + steps	Only logic
Use case	CI/CD pipelines	Small tasks (login, setup)
Example	Build + test + deploy	actions/checkout
🌍 Real-world example
Action:
uses: actions/checkout@v4

👉 Just checks out code

Reusable Workflow:
uses: ./.github/workflows/build.yml

👉 Runs full pipeline (build + test)

🧠 4. Where must it live?

👉 Must be inside:

.github/workflows/

Example:

.github/workflows/reusable.yml



### Task 5: Create a Composite Action
Create a **custom composite action** in your repo at `.github/actions/setup-and-greet/action.yml`:
1. Define inputs: `name` and `language` (default: `en`)
2. Add steps that:
   - Print a greeting in the specified language
   - Print the current date and runner OS
   - Set an output called `greeted` wxith value `true`
3. Use the composite action in a new workflow with `uses: ./.github/actions/setup-and-greet`

**Verify:** Does your custom action run and print the greeting?
name: setup-and-greet

inputs:
  name:
    required: true
    type: string

  language:
    required: false
    type: string
    default: en

outputs:
  greeted:
    value: ${{ steps.output-step.outputs.greeted }}

runs:
  using: "composite"
  steps:
    - name: print inputs
      shell: bash
      run: |
        echo "Language: ${{ inputs.language }}"
        echo "Name: ${{ inputs.name }}"

    - name: print system info
      shell: bash
      run: |
        echo "Date: $(date)"
        echo "OS: $RUNNER_OS"

    - name: set output
      id: output-step
      shell: bash
      run: |
        echo "greeted=true" >> $GITHUB_OUTPUT
---

### Task 6: Reusable Workflow vs Composite Action
Fill this in your notes:

| | Reusable Workflow | Composite Action |
|---|---|---|
| Triggered by | `workflow_call` | `uses:` in a step |
| Can contain jobs? | ? | ? |
| Can contain multiple steps? | ? | ? |
| Lives where? | ? | ? |
| Can accept secrets directly? | ? | ? |
| Best for | ? | ? |
|                              | Reusable Workflow    | Composite Action                   |
| ---------------------------- | -------------------- | ---------------------------------- |
| Triggered by                 | `workflow_call`      | `uses:` in a step                  |
| Can contain jobs?            | ✅ Yes                | ❌ No                               |
| Can contain multiple steps?  | ✅ Yes                | ✅ Yes                              |
| Lives where?                 | `.github/workflows/` | `.github/actions/` (or any folder) |
| Can accept secrets directly? | ✅ Yes                | ❌ No (must pass via env/input)     |
| Best for                     | Full CI/CD pipelines | Reusable step logic                |
