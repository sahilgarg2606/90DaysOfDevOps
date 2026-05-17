1. Create a Deployment with 3 replicas using nginx
apiVersion: apps/v1
kind: Deployment
metadata: 
    name: nginx
    namespace: nginx-namespace
    labels:
       app: nginx
spec:
    replicas: 3
    selector: 
        matchLabels:
            app: nginx
    template:
        metadata:
           labels:
              app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:1.14.2
            ports:
            - containerPort: 80 

        
2. Check the pod names — they are random (`app-xyz-abc`)
yes pods gets random names like 
nginx-77bc6bd484-kp25q
3. Delete a pod and notice the replacement gets a different random name
kubectl delete pod -n nginx-namespace  nginx-77bc6bd484-tjb5v
This is fine for web servers but not for databases where you need stable identity.

| Feature | Deployment | StatefulSet |
|---|---|---|
| Pod names | Random | Stable, ordered (`app-0`, `app-1`) |
| Startup order | All at once | Ordered: pod-0, then pod-1, then pod-2 |
| Storage | Shared PVC | Each pod gets its own PVC |
| Network identity | No stable hostname | Stable DNS per pod |

Delete the Deployment before moving on.

**Verify:** Why would random pod names be a problem for a database cluster?
In short, random pod names are unsuitable for database clusters because they break stable identity, persistent storage mapping, and ordered startup, all of which are essential for reliable database operation. Using StatefulSets with deterministic pod names ensures data integrity, predictable networking, and easier management in Kubernetes environments. 


### Task 2: Create a Headless Service
1. Write a Service manifest with `clusterIP: None` — this is a Headless Service
2. Set the selector to match the labels you will use on your StatefulSet pods
3. Apply it and confirm CLUSTER-IP shows `None`
apiVersion: v1
kind: Service
metadata:
   name: mysql-svc
spec:
    clusterIP: None
    selector:
      app: mysql-stateful
    ports:
    - port: 3306

A Headless Service creates individual DNS entries for each pod instead of load-balancing to one IP. StatefulSets require this.

**Verify:** What does the CLUSTER-IP column show?
None


### Task 3: Create a StatefulSet
1. Write a StatefulSet manifest with `serviceName` pointing to your Headless Service
2. Set replicas to 3, use the nginx image
3. Add a `volumeClaimTemplates` section requesting 100Mi of ReadWriteOnce storage
4. Apply and watch: `kubectl get pods -l <your-label> -w`
kind: StatefulSet
apiVersion: apps/v1
metadata:
   name: mysql-stateful
   labels:
      app: mysql-stateful
spec:
   serviceName: "mysql-stateful"
   replicas: 3
   selector:
      matchLabels:
          app: mysql-stateful
   template:
       metadata:
          labels:
             app: mysql-stateful
       spec:
          containers:
          - name: mysql
            image: mysql:8.0
            env:
              - name: MYSQL_ROOT_PASSWORD
                value: root123
            ports:
            - containerPort: 3306
            volumeMounts:
            - name: mysql-storage
              mountPath: /var/lib/mysql
   volumeClaimTemplates:
      - metadata:
           name: mysql-storage
        spec:
           accessModes: ["ReadWriteOnce"]
           resources:
              requests:
                 storage: 500Mi


Observe ordered creation — `web-0` first, then `web-1` after `web-0` is Ready, then `web-2`.

Check the PVCs: `kubectl get pvc` — you should see `web-data-web-0`, `web-data-web-1`, `web-data-web-2` (names follow the pattern `<template-name>-<pod-name>`).
NAME                             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
mysql-storage-mysql-stateful-0   Bound    pvc-b8a756d2-0007-4672-97bf-fb1edb382f4d   500Mi      RWO            standard       <unset>                 27m
mysql-storage-mysql-stateful-1   Bound    pvc-d9c59f00-f9e6-4596-a0b9-3a81ec77f7fd   500Mi      RWO            standard       <unset>                 27m
mysql-storage-mysql-stateful-2   Bound    pvc-0105ec1e-2353-4a90-990b-d0053c38c779   500Mi      RWO            standard       <unset>                 56s
**Verify:** What are the exact pod names and PVC names?
pod names are mysql-stateful-0 , 1,2
and pvc names are mysql-storage-mysql-stateful-0,1,2    