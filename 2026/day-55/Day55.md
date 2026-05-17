## Challenge Tasks

### Task 1: See the Problem — Data Lost on Pod Deletion
1. Write a Pod manifest that uses an `emptyDir` volume and writes a timestamped message to `/data/message.txt`
kind: Pod
apiVersion: v1
metadata:
    name: data-lost-demo
    labels:
        app: data-lost

spec:
     containers:
        - name: nginx
          image: ubuntu:22.04
          command:
            - sh
            - -c
            - |
              echo "$(date '+%Y-%m-%d %H:%M:%S') - Hello from Kubernetes Pod!" > /data/message.txt
              while true; do
              sleep 5
              done
          volumeMounts:
            - mountPath: /data
              name: cache-volume
     volumes:
      - name: cache-volume
        emptyDir: {}
           
  
2. Apply it, verify the data exists with `kubectl exec`
kubectl exec -it data-lost-demo -- sh

3. Delete the Pod, recreate it, check the file again — the old message is gone
kubectl delete pod data-lost-demo
kubectl apply -f data-lost-demo.yml
**Verify:** Is the timestamp the same or different after recreation?
no the timeSttamp is different after recreation because when we delete the pod data gets also deleteed that is why when we apply the config again then recreated it 


### Task 2: Create a PersistentVolume (Static Provisioning)
1. Write a PV manifest with `capacity: 1Gi`, `accessModes: ReadWriteOnce`, `persistentVolumeReclaimPolicy: Retain`, and `hostPath` pointing to `/tmp/k8s-pv-data`
apiVersion: v1
kind: PersistentVolume
metadata: 
    name: my-app-pv
spec:
   storageClassName: "manual"
   persistentVolumeReclaimPolicy: Retain
   capacity:
       storage: 1Gi
   accessModes:
      - ReadWriteOnce
   hostPath:
    path: "/tmp/k8s-pv-data"

2. Apply it and check `kubectl get pv` — status should be `Available`
kubectl get pv 
yes it is showing me available 
Access modes to know:
- `ReadWriteOnce (RWO)` — read-write by a single node
- `ReadOnlyMany (ROX)` — read-only by many nodes
- `ReadWriteMany (RWX)` — read-write by many nodes

`hostPath` is fine for learning, not for production.

**Verify:** What is the STATUS of the PV?
status of Pv is Available

### Task 3: Create a PersistentVolumeClaim
1. Write a PVC manifest requesting `500Mi` of storage with `ReadWriteOnce` access
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: my-app-pvc
spec:
    storageClassName: ""
    accessModes:
       - ReadWriteOnce
    resources:
       requests:
          storage: 1Gi
    selector:
       matchLabels:
           app: my-app-pv
2. Apply it and check both `kubectl get pvc` and `kubectl get pv`
kubectl get pvc 
kubectl get pv
3. Both should show `Bound` — Kubernetes matched them by capacity and access mode

**Verify:** What does the VOLUME column in `kubectl get pvc` show?
NAME         STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
my-app-pvc   Bound    my-app-pv   1Gi        RWO                           <unset>                 16s
yes kubectl get pvc showing bound with pv because all of the things like storageclass and storage requrest is matching


### Task 5: StorageClasses and Dynamic Provisioning

1. Run `kubectl get storageclass` and `kubectl describe storageclass`
2. Note the provisioner, reclaim policy, and volume binding mode
Provisioner:           rancher.io/local-path
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
3. With dynamic provisioning, developers only create PVCs — the StorageClass handles PV creation automatically

**Verify:** What is the default StorageClass in your cluster?
Standard storage class is the default storage class in the cluster


### Task 6: Dynamic Provisioning
1. Write a PVC manifest that includes `storageClassName: standard` (or your cluster's default)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: my-pvc
spec:
    accessModes:
       - ReadWriteOnce
    storageClassName: standard
    resources:
       requests:
          storage: 1Gi
2. Apply it — a PV should appear automatically in `kubectl get pv`
when i do kubectl get pv then automatically pv doesnot come because standard class follow the policy of WaitForFirstConsumer that means when pvc is used in some port then only pv will be gets created
3. Use this PVC in a Pod, write data, verify it works

**Verify:** How many PVs exist now? Which was manual, which was dynamic?
now two pv exist the one is that i have manuallly created and the other one is of that has been created automatically by storageclass: standard
---


### Task 7: Clean Up
1. Delete all pods first
kubectl delete pod data-persist
kubectl delete pod standard-data-persist
2. Delete PVCs — check `kubectl get pv` to see what happened
kubectl delete pvc my-app-pvc
kubectl get pv
3. The dynamic PV is gone (Delete reclaim policy). The manual PV shows `Released` (Retain policy).
yes the dynamic pv is automatically gone because of its default recliam policy is of deleted 
yes the manual pv is show released 
4. Delete the remaining PV manually

**Verify:** Which PV was auto-deleted and which was retained? Why?

---