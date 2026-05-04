### Task 1: Create a ConfigMap from Literals
1. Use `kubectl create configmap` with `--from-literal` to create a ConfigMap called `app-config` with keys `APP_ENV=production`, `APP_DEBUG=false`, and `APP_PORT=8080`
kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_DEBUG=false --from-literal=APP_PORT=8080
2. Inspect it with `kubectl describe configmap app-config` and `kubectl get configmap app-config -o yaml`
 kubectl get configmap app-config -o yaml
 apiVersion: v1
data:
  APP_DEBUG: "false"
  APP_ENV: production
  APP_PORT: "8080"
kind: ConfigMap
metadata:
  creationTimestamp: "2026-05-04T18:07:43Z"
  name: app-config
  namespace: default
  resourceVersion: "82961"
  uid: 66132aea-69e0-49f6-b5f6-bb65175d81c7
3. Notice the data is stored as plain text — no encoding, no encryption
yes data is stored in configMaps are plain text

**Verify:** Can you see all three key-value pairs?
yes

### Task 2: Create a ConfigMap from a File
1. Write a custom Nginx config file that adds a `/health` endpoint returning "healthy"
server {
    listen 80;
    server_name _;

    location /health {
        default_type text/plain;
        return 200 'healthy';
    }

    # Optional: root location for other requests
    location / {
        return 200 'Welcome to Nginx!';
    }
}

2. Create a ConfigMap from this file using `kubectl create configmap nginx-config --from-file=default.conf=<your-file>`
3. The key name (`default.conf`) becomes the filename when mounted into a Pod

**Verify:** Does `kubectl get configmap nginx-config -o yaml` show the file contents?
yes 


### Task 3: Use ConfigMaps in a  Pod
1. Write a Pod manifest that uses `envFrom` with `configMapRef` to inject all keys from `app-config` as environment variables. Use a busybox container that prints the values.
apiVersion: v1
kind: Pod
metadata:
  name: config-user
  labels:
    app: config-user
    environment: dev
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command: ["sh", "-c", "sleep 3600"]
    envFrom:
     - configMapRef:
          name: app-config
2. Write a second Pod manifest that mounts `nginx-config` as a volume at `/etc/nginx/conf.d`. Use the nginx image.
kind: Pod
apiVersion: v1
metadata: 
   name: nginx-pod
spec:
   containers:
      - name: nginx
        image: nginx:latest
        ports:
           - containerPort: 80   
        volumeMounts:
            - name: config
              mountPath: /etc/nginx/conf.d

   volumes:
    - name: config
      configMap:
        name: nginx-config
3. Test that the mounted config works: `kubectl exec <pod> -- curl -s http://localhost/health`
healthy
Use environment variables for simple key-value settings. Use volume mounts for full config files.

**Verify:** Does the `/health` endpoint respond?
yess

### Task 4: Create a Secret
1. Use `kubectl create secret generic db-credentials` with `--from-literal` to store `DB_USER=admin` and `DB_PASSWORD=s3cureP@ssw0rd`
 kubectl create secret generic db-credentials --from-literal=DB_USER=YWRtaW4= --from-literal=DB_PASS=czNjdXJlUEBzc3cwcmQ=
2. Inspect with `kubectl get secret db-credentials -o yaml` — the values are base64-encoded
apiVersion: v1
data:
  DB_PASS: Y3pOamRYSmxVRUJ6YzNjd2NtUT0=
  DB_USER: WVdSdGFXND0=
kind: Secret
metadata:
  creationTimestamp: "2026-05-04T19:16:10Z"
  name: db-credentials
  namespace: default
  resourceVersion: "89251"
  uid: 2146dc4e-897d-4fd6-83b4-0ee03d74a324
type: Opaque
3. Decode a value: `echo '<base64-value>' | base64 --decode`

**base64 is encoding, not encryption.** Anyone with cluster access can decode Secrets. The real advantages are RBAC separation, tmpfs storage on nodes, and optional encryption at rest.

**Verify:** Can you decode the password back to plaintext?
yes we can decode it


### Task 5: Use Secrets in a Pod
1. Write a Pod manifest that injects `DB_USER` as an environment variable using `secretKeyRef`
apiVersion: v1
kind: Pod
metadata:
  name: secret-user
spec:
  containers:
    - name: busybox
      image: busybox:latest
      command: ["sh", "-c", "sleep 3600"]

      env:
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: DB_USER

      volumeMounts:
        - name: secret-volume
          mountPath: /etc/db-credentials
          readOnly: true

  volumes:
    - name: secret-volume
      secret:
        secretName: db-credentials
2. In the same Pod, mount the entire `db-credentials` Secret as a volume at `/etc/db-credentials` with `readOnly: true`
3. Verify: each Secret key becomes a file, and the content is the decoded plaintext value
plainText
**Verify:** Are the mounted file values plaintext or base64?
plain text

1. Create a ConfigMap `live-config` with a key `message=hello`
2. Write a Pod that mounts this ConfigMap as a volume and reads the file in a loop every 5 seconds
3. Update the ConfigMap: `kubectl patch configmap live-config --type merge -p '{"data":{"message":"world"}}'`
4. Wait 30-60 seconds — the volume-mounted value updates automatically
5. Environment variables from earlier tasks do NOT update — they are set at pod startup only

**Verify:** Did the volume-mounted value change without a pod restart?
yes
