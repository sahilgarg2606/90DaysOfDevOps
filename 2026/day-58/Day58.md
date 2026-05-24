
### Task 1: Install the Metrics Server
1. Check if it is already running: `kubectl get pods -n kube-system | grep metrics-server`
2. If not, install it:
   - Minikube: `minikube addons enable metrics-server`
   - Kind/kubeadm: apply the official manifest from the metrics-server GitHub releases
3. On local clusters, you may need the `--kubelet-insecure-tls` flag (never in production)
https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value":"--kubelet-insecure-tls"}]'
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP
4. Wait 60 seconds, then verify: `kubectl top nodes` and `kubectl top pods -A`
kubectl top nodes
kubectl top pods -A
**Verify:** What is the current CPU and memory usage of your node?
NAME                        CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
tws-cluster-control-plane   257m         6%       711Mi           18%         
tws-cluster-worker          45m          1%       307Mi           8%          
tws-cluster-worker2         40m          1%       282Mi           7%     

### Task 2: Explore kubectl top
1. Run `kubectl top nodes`, `kubectl top pods -A`, `kubectl top pods -A --sort-by=cpu`
2. `kubectl top` shows real-time usage, not requests or limits — these are different things
3. Data comes from the Metrics Server, which polls kubelets every 15 seconds
#checking the resources consuming by nodes
kubectl top nodes

#checking the resources consuming by pods in default namespace
kubectl top pods
kubectl top pods -n bankapp // checking in the bankapp namespace
#checking the resouves consumed by all the pods
kubectl top pods -A 
#sorting the consumed data by cpu
kubectl top pods -A --sort-by=cpu
**Verify:** Which pod is using the most CPU right now?
kube-apiserver-tws-cluster-control-plane 
in the whole cluster api server is using most cpu



### Task 3: Create a Deployment with CPU Requests
1. Write a Deployment manifest using the `registry.k8s.io/hpa-example` image (a CPU-intensive PHP-Apache server)
2. Set `resources.requests.cpu: 200m` — HPA needs this to calculate utilization percentages
3. Expose it as a Service: `kubectl expose deployment php-apache --port=80`
apiVersion: apps/v1
kind: Deployment
metadata:
     name: apache
     labels:
         app: apache
spec:
   selector:
       matchLabels:
            app: apache
   template:
       metadata:
           labels:
               app: apache
       spec: 
           containers:
            - name: apacheee
              image: registry.k8s.io/hpa-example
              resources:
                  requests:
                      cpu: "200m"        
   
Without CPU requests, HPA cannot work — this is the most common HPA setup mistake.

**Verify:** What is the current CPU usage of the Pod?
19m


### Task 4: Create an HPA (Imperative)
1. Run: `kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10`
2. Check: `kubectl get hpa` and `kubectl describe hpa php-apache`
3. TARGETS may show `<unknown>` initially — wait 30 seconds for metrics to arrive

This scales up when average CPU exceeds 50% of requests, and down when it drops below.

**Verify:** What does the TARGETS column show?
NAME     REFERENCE           TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
apache   Deployment/apache   cpu: 0%/50%   1         10        1          3m35s


### Task 5: Generate Load and Watch Autoscaling
1. Start a load generator: `kubectl run load-generator --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"`
2. Watch HPA: `kubectl get hpa php-apache --watch`
3. Over 1-3 minutes, CPU climbs above 50%, replicas increase, CPU stabilizes
4. Stop the load: `kubectl delete pod load-generator`
5. Scale-down is slow (5-minute stabilization window) — you do not need to wait

**Verify:** How many replicas did HPA scale to under load?
they scale total 10 replicas when they are under load that they stablize it

### Task 6: Create an HPA from YAML (Declarative)
1. Delete the imperative HPA: `kubectl delete hpa php-apache`
2. Write an HPA manifest using `autoscaling/v2` API with CPU target at 50% utilization
3. Add a `behavior` section to control scale-up speed (no stabilization) and scale-down speed (300 second window)
4. Apply and verify with `kubectl describe hpa`
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
    name: apache
spec:
    scaleTargetRef:
       apiVersion: apps/v1
       kind: Deployment
       name: apache
    minReplicas: 1
    maxReplicas: 10
    metrics:
    - type: Resource
      resource:
         name: cpu
         target:
             type: Utilization
             averageUtilization: 50
    behavior:
     scaleDown:
      stabilizationWindowSeconds: 300
`autoscaling/v2` supports multiple metrics and fine-grained scaling behavior that the imperative command cannot configure.

**Verify:** What does the `behavior` section control?
Behavior section control karta hai:
HPA kitni fast scale up/down karega

### Task 3: Install Ansible
Install Ansible on your **control node** (your laptop or one dedicated EC2 instance):

```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt update
sudo apt install ansible -y

# Amazon Linux / RHEL
sudo yum install ansible -y
# or
pip3 install ansible

# Verify
ansible --version
```

Confirm the output shows the Ansible version, config file path, and Python version.

**Document:** On which machine did you install Ansible? Why is it only needed on the control node?