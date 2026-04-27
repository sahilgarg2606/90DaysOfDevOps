### Task 1: Recall the Kubernetes Story
Before touching a terminal, write down from memory:

1. Why was Kubernetes created? What problem does it solve that Docker alone cannot?
kubernetes created because google wont be able scale their applications effiencitly if they able to scale their application then resources usage becames very high that resultens in the delayed deploymeent high resourses usage high cost soo that is why they created the application named borg which is used to scale the applcation containers and later they open source it and donate it to the adopted by the linux foundation company named CNCI 
kubernetes solves the problem of manual scaling and manual restarting the container when crash occured 
2. Who created Kubernetes and what was it inspired by?
kubernetes is intially created by the google then it later adopted by the CNCI company 
Kubernetes can be traced back to 2013 when three engineers at Google—Craig McLuckie, Joe Beda, and Brendan Burns—pitched the idea of building an open-source container management system.
It was inspired by Google’s internal system called Borg, which they had been using for years to manage large-scale containerized applications.
3. What does the name "Kubernetes" mean?
The name Kubernetes comes from Greek.

👉 It means “helmsman” or “pilot” — someone who steers a ship.

💡 That’s why you’ll often see the ship wheel ⚓ symbol associated with Kubernetes:

It represents guiding and managing containers, just like a helmsman steers a ship.

Fun fact:
The abbreviation “K8s” comes from the 8 letters between K and s in Kubernetes.
Do not look anything up yet. Write what you remember from the session, then verify against the official docs.


### Task 2: Draw the Kubernetes Architecture
From memory, draw or describe the Kubernetes architecture. Your diagram should include:

**Control Plane (Master Node):**
- API Server — the front door to the cluster, every command goes through it
- etcd — the database that stores all cluster state
- Scheduler — decides which node a new pod should run on
- Controller Manager — watches the cluster and makes sure the desired state matches reality

**Worker Node:**
- kubelet — the agent on each node that talks to the API server and manages pods
- kube-proxy — handles networking rules so pods can communicate
- Container Runtime — the engine that actually runs containers (containerd, CRI-O)

After drawing, verify your understanding:
- What happens when you run `kubectl apply -f pod.yaml`? Trace the request through each component.
kubectl --> api server
your request hits to api server

api server ---> etcd 
the desired state stored in etcd

scheduler wakes up
Sees a new Pod with no node → chooses best Worker Node

API Server updates assignment
Pod is now assigned to a node

kubelet (on that node)
reads from api server --> creates the pod
container runtime
Pulls image & starts container
Controller Manager
Keeps watching → ensures Pod stays running
- What happens if the API server goes down?
you cannot run kubectl commands 
no news pods can be schedulted
already running pods remain as it is 
but cluster becames unmanageable
- What happens if a worker node goes down?
pods on that worker node gone
controller manager detects that failure
scheduler create new pods on healthy nodes 

Think of this as the brain of Kubernetes.

API Server → Entry point of the cluster (all commands go here)
etcd → Key-value database storing cluster state
Scheduler → Decides where a Pod should run
Controller Manager → Ensures desired state = actual state

Think of this as the brain of Kubernetes.

API Server → Entry point of the cluster (all commands go here)
etcd → Key-value database storing cluster state
Scheduler → Decides where a Pod should run
Controller Manager → Ensures desired state = actual state

---

### Task 4: Set Up Your Local Cluster
Choose **one** of the following. Both give you a fully functional Kubernetes cluster on your machine.

**Option A: kind (Kubernetes in Docker)**
```bash
# Install kind
# macOS
brew install kind

# Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create a cluster
kind create cluster --name devops-cluster
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: devops-cluster

nodes:

- role: control-plane
  image: kindest/node:v1.35.0

- role: worker
  image: kindest/node:v1.35.0

- role: worker
  image: kindest/node:v1.35.0
  
- role: worker
  image: kindest/node:v1.35.0


# Verify
kubectl cluster-info
kubectl get nodes
```

### Task 5: Explore Your Cluster
Now that your cluster is running, explore it:

```bash
# See cluster info
kubectl cluster-info

# List all nodes
kubectl get nodes

# Get detailed info about your node
kubectl describe node <node-name>

# List all namespaces
kubectl get namespaces

# See ALL pods running in the cluster (across all namespaces)
kubectl get pods -A
```

Look at the pods running in the `kube-system` namespace:
```bash
kubectl get pods -n kube-system

---

### Task 6: Practice Cluster Lifecycle
Build muscle memory with cluster operations:

kind delete cluster --name devops-cluster

kind create cluster --name devops-cluster

kubectl get nodes
Try these useful commands:
```bash
# Check which cluster kubectl is connected to
kubectl config current-context

# List all available contexts (clusters)
kubectl config get-contexts

# See the full kubeconfig
kubectl config view