### Task 1: Key-Value Pairs
Create `person.yaml` that describes yourself with:
- `name`
- `role`
- `experience_years`
- `learning` (a boolean)

name: sahil
role: software engineer
experience: 1 years
learning: true

**Verify:** Run `cat person.yaml` — does it look clean? No tabs?
yes the output is clean no tabs and spaces is there



### Task 2: Lists
Add to `person.yaml`:
- `tools` — a list of 5 DevOps tools you know or are learning
- `hobbies` — a list using the inline format `[item1, item2]`

Write in your notes: What are the two ways to write a list in YAML?
above is the two ways for writing the list in YAML
tools:
  - python
  - java
  - javascript
hobbies: [coding, gaming, traveling]



### Task 3: Nested Objects
Create `server.yaml` that describes a server:
- `server` with nested keys: `name`, `ip`, `port`
- `database` with nested keys: `host`, `name`, `credentials` (nested further: `user`, `password`)
server:
   name: my-server
   ip: 192.196.34.5
   ports: [80, 443, 8080]

database:
   host: localhost
   name: root
   credentials:
      username: admin
      password: 12345

**Verify:** Try adding a tab instead of spaces — what happens when you validate it?
YAML tabs allow nahi karta
Sirf spaces (usually 2 spaces) use karte ha


### Task 4: Multi-line Strings
In `server.yaml`, add a `startup_script` field using:
1. The `|` block style (preserves newlines)
2. The `>` fold style (folds into one line)
  script_literal: |
    echo "starting server"
    npm install
    npm start
  script_folded: >
    echo "starting server"
    npm install
    npm start
Write in your notes: When would you use `|` vs `>`?
| literal Block perserves newlines
output will look exactly same 
echo "starting server"
npm install
npm start

> folded blocks
output will look like
echo "Starting server..." npm install npm start


### Task 5: Validate Your YAML
1. Install `yamllint` or use an online validator
2. Validate both your YAML files
3. Intentionally break the indentation — what error do you get?
4. Fix it and validate again
Why error aata hai?

 YAML mein indentation hi structure define karta hai
 Agar spacing inconsistent ho gayi → parser confuse ho jata hai


### Task 6: Spot the Difference
Read both blocks and write what's wrong with the second one:

```yaml
# Block 1 - correct
name: devops
tools:
  - docker
  - kubernetes
```

```yaml
# Block 2 - broken
name: devops
tools:
- docker
  - kubernetes
```
the difference of above two is of spacing on second items of tools list 