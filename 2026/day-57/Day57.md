### Task 1: Resource Requests and Limits
1. Write a Pod manifest with `resources.requests` (cpu: 100m, memory: 128Mi) and `resources.limits` (cpu: 250m, memory: 256Mi)
apiVersion: v1
kind: Pod
metadata:
    name: nginx-server
spec:
    containers:
     - name: nginx
       image: nginx:1.14.2
       ports:
       - containerPort: 80
       resources:
          requests:
              memory: "128Mi"
              cpu: "100m"
          limits:
              memory: "256Mi"
              cpu: "250m"        
2. Apply and inspect with `kubectl describe pod` — look for the Requests, Limits, and QoS Class sections
3. Since requests and limits differ, the QoS class is `Burstable`. If equal, it would be `Guaranteed`. If missing, `BestEffort`.

CPU is in millicores: `100m` = 0.1 CPU. Memory is in mebibytes: `128Mi`.

**Requests** = guaranteed minimum (scheduler uses this for placement). **Limits** = maximum allowed (kubelet enforces at runtime).

**Verify:** What QoS class does your Pod have?
Burstable
Qos meaning the Quality of service it means which is killed first when resource gets consumed burstable is at the middle and Guranteed is most protected one 



### Task 2: OOMKilled — Exceeding Memory Limits
1. Write a Pod manifest using the `polinux/stress` image with a memory limit of `100Mi`
2. Set the stress command to allocate 200M of memory: `command: ["stress"] args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]`
apiVersion: v1
kind: Pod
metadata: 
    name: sserver
spec:
    containers:
     - name: stress
       image: polinux/stress
       command: ["stress"]
       args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]
       resources:
           requests:
               cpu: "100m"
               memory: "100Mi"
           limits:
               cpu: "100m"
               memory: "100Mi"

3. Apply and watch — the container gets killed immediately
yes container is killed
CPU is throttled when over limit. Memory is killed — no mercy.

Check `kubectl describe pod` for `Reason: OOMKilled` and `Exit Code: 137` (128 + SIGKILL).

**Verify:** What exit code does an OOMKilled container have? 
137   


### Task 3: Pending Pod — Requesting Too Much
1. Write a Pod manifest requesting `cpu: 100` and `memory: 128Gi`
2. Apply and check — STATUS stays `Pending` forever
3. Run `kubectl describe pod` and read the Events — the scheduler says exactly why: insufficient resources
apiVersion: v1
kind: Pod
metadata:
    name: nginx-server
spec:
    containers:
     - name: nginx
       image: nginx:1.14.2
       ports:
       - containerPort: 80
       resources:
          requests:
              memory: "128Gi"
              cpu: "100"
          limits:
              memory: "256Gi"
              cpu: "750"    
**Verify:** What event message does the scheduler produce?
ype     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  12s   default-scheduler  0/3 nodes are available: 1 node(s) had untolerated taint(s), 2 Insufficient cpu, 2 Insufficient memory. no new claims to deallocate, preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.


### Task 4: Liveness Probe
A liveness probe detects stuck containers. If it fails, Kubernetes restarts the container.

1. Write a Pod manifest with a busybox container that creates `/tmp/healthy` on startup, then deletes it after 30 seconds
2. Add a liveness probe using `exec` that runs `cat /tmp/healthy`, with `periodSeconds: 5` and `failureThreshold: 3`
3. After the file is deleted, 3 consecutive failures trigger a restart. Watch with `kubectl get pod -w`
apiVersion: v1
kind: Pod 
metadata:
    name: liveness
spec:
    containers:
     - name: busybox
       image: busybox:latest
       command:
          - sh
          - -c
          - |
            touch /tmp/healthy
            echo "file created successfully"
            sleep 30
            rm -f /tmp/healthy
            echo "file deleted"
            while true; do sleep 5; done
       livenessProbe:
           exec:
               command:
               - cat
               - /tmp/healthy
           initialDelaySeconds: 5
           periodSeconds: 5
           failureThreshold: 3
           
**Verify:** How many times has the container restarted?    
Restart count continuously increase karega 


### Task 5: Readiness Probe
A readiness probe controls traffic. Failure removes the Pod from Service endpoints but does NOT restart it.

1. Write a Pod manifest with nginx and a `readinessProbe` using `httpGet` on path `/` port `80`
2. Expose it as a Service: `kubectl expose pod <name> --port=80 --name=readiness-svc`
3. Check `kubectl get endpoints readiness-svc` — the Pod IP is listed
4. Break the probe: `kubectl exec <pod> -- rm /usr/share/nginx/html/index.html`
5. Wait 15 seconds — Pod shows `0/1` READY, endpoints are empty, but the container is NOT restarted
apiVersion: v1
kind: Pod
metadata:
    name: readiness
spec:
    containers:
     - name: nginx
       image: nginx:1.14.2
       ports:
       - containerPort: 80
       readinessProbe:
           httpGet:
               path: /
               port: 80
           periodSeconds: 5

**Verify:** When readiness failed, was the container restarted?
no pod doesnot restart in this readiness probe
the main purpose of Readiness probe is to chech whether the pod is ready to take the traffic not to restart the container


### Task 6: Startup Probe
A startup probe gives slow-starting containers extra time. While it runs, liveness and readiness probes are disabled.

1. Write a Pod manifest where the container takes 20 seconds to start (e.g., `sleep 20 && touch /tmp/started`)
2. Add a `startupProbe` checking for `/tmp/started` with `periodSeconds: 5` and `failureThreshold: 12` (60 second budget)
3. Add a `livenessProbe` that checks the same file — it only kicks in after startup succeeds

**Verify:** What would happen if `failureThreshold` were 2 instead of 12?
if the failurethreshold is 2 instead of 12 then startup probe will only 10 seconds will be given if still file not found then it will restart the container again 
apiVersion: v1
kind: Pod 
metadata:
    name: startup
spec:
    containers:
     - name: busybox
       image: busybox:latest
       command:
          - sh
          - -c
          - |
            sleep 20
            touch /tmp/startup
            echo "file created successfully"
            while true; do sleep 5; done
       startupProbe:
           exec:
               command:
               - cat
               - /tmp/startup
           periodSeconds: 5
           failureThreshold: 12
           