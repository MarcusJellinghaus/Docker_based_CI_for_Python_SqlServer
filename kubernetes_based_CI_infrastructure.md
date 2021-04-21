# Kubernetes

Kubernetes allows to properly manage hundreds of containers with the features likes scablability or high performance, high availablility or no downtime,  and disaster recover with backup and restore.

## Kubernetes components

Kubernetes includes these components:

- *Node*: Machine to run Kubernetes
- *Pod*: Abstraction over a container, like docker container and container image, abstraction to work only with kubernetes without using eg docker. Usually one application is executed on a pod. Each pod gets its own ip adress. If a pod dies and gets recreated, it gets a new IP adress.
- *Service*: A service has a permanent IP adress to abstract from pods when they die and get recreated. A service also distributes the workload over its different pods.
- *Ingress*: An ingress allows to expose IP services to an external network and route traffic inside the cluster.
- *ConfigMap*: Configuration information, environment variables etc. should be stored outside the built application and outside the container image. All of this should be stored in a *ConfigMap*.
- *Secrets*: Configuration details like username and password should be stored in secrets. Secrets are base64 encoded.
- *Volumes* or *persistent volumes*: Data should be stored outside an image, so that it is not gone after a restart of a pod. Eg db data should be stored on a physical storage outside the image in a volume, and will be loaded from this persistent storage. Storage could be local or remote. Kubernetes does not manage data persistence.
- *Replicas*: Replicas allow to have the same pod several times. Eg if one node goes down, the replicate on another node is still responsive - so the service has higher availability. Having several nodes also improves the performance.
- *Deployment*: Blueprint for pods, also containing the number of replicas that should be run. Most of the time, you work with deployments, not with pods. Deployments should be only used for stateless services (that do not use a volume)
- *Stateful Set*: Allows to replicate services that need a volume, eg a database service. Stateful sets allow for replication between several copies of a stateful set. StatefulSets are complicated, therefore DBs are often hosted outside of a Kubernetes cluser.

- Other objects kubernetes objects include:

    - Namespace
    - Replica Set
    - Replication controller
    - deployment
    - dir / directory of configfile (?)
    - namespace
    - persistent volume claim
    - Storage Class
    - Cron Jobs
    - Daemon Sets
    - Jobs

## Kubernetes commands

- `kubectl`: The kubectl command line tool lets you control Kubernetes clusters [docs](https://kubernetes.io/docs/reference/kubectl/overview/). It allows to talk to Api Server - both for a minikube setup or a cloud cluster. Install package is called kubernetes-cli.
- `kubeadm`: the [command](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) to bootstrap the cluster.
- `kubelet`: the component that runs on all of the machines in your cluster and does things like starting pods and containers.

## Installation of kubectl on a client machine

To install kubectl, type `choco install kubernetes-cli`

## Kubernetes setup

### Example for a simple setup

A simple setup can consist of eg one node with 2 services running on it. Each node contains three processes:

    - *container runtime*: eg docker to run a container
    - *kubelet* interacts with the node and the containers. A kubelet starts the pod with a container inside.
    - A *kube proxy* forwards communication to a certain services/

### Example for a replicated setup with several nodes

There are several nodes which replicate each other. Beside the worked nodes, there are also master nodes.

- Worker nodes gets managed by a master node. The communcation between nodes happends via Services

- Each master node runs four different processes:

    - Api Server:

        - cluster gateway, validates requests and forwards them to pod
        - acts as gatekeeper for authentication

    - Scheduler:

        - starts the pods by talking to the kubelet, decides where to start them, also looking at available resources on nodes

    - Controller manager:

        - detects cluster state changes, eg if a pod dies, talks to scheduler in case needed

    - etcd: Key value store of the cluster state, persists the kubernetes (management) information. Actual application data is not stored there. Distributed storage across the master node.

- Example cluster setup:

    - 2 masters with less resources,
    - 3 nodes with more resources. Add nodes if workload increases.
    - In general, add a node, install master/node processes, add it to the cluster

## Different variations

Kubernetes has several different extensions or modules of different providers.

- Kubernetes distributions: Kubernetes can be executed by different software:
    - Kubernetes (K8S): https://kubernetes.io/
    - [K3S](https://k3s.io/) - Lightweight Kubernetes
    - [Minikube](https://kubernetes.io/de/docs/setup/minikube/) allows for a one node cluster with docker pre-installed and the master and worker processes, eg for a developer machine.
    - [Kind](https://kind.sigs.k8s.io/): Allows to execute kubernetes on docker nodes.
    - [MicroK8s](https://microk8s.io/) 
        - [Kubernetes on Windows with MicroK8s and WSL 2](https://ubuntu.com/blog/kubernetes-on-windows-with-microk8s-and-wsl-2)

- Different drivers for the virtual machines: Minikube / Kubernetes can be executed inside virtual machines or directly on a machine. A variety of virtual machines are supported - see [https://kubernetes.io/de/docs/setup/minikube/](https://kubernetes.io/de/docs/setup/minikube/).

- Container runtimes: A container runtime is responsible for running containers. Examples for container runtimes include Docker and containerd.

- Data can be stored on volumes outside a container. There is a variety of volumes supported - see [https://kubernetes.io/docs/concepts/storage/volumes/](https://kubernetes.io/docs/concepts/storage/volumes/).
    - A `hostPath` volume mounts a file or directory from the host node's filesystem into your Pod.
    - A `glusterfs` volume allows a Glusterfs (an open source networked filesystem) volume to be mounted into your Pod. [Examples](https://github.com/kubernetes/examples/tree/master/volumes/glusterfs). Gluster can not be installed on Windows.
    - NFS: Kubernetes can use a network file system (NFS) to store volumes. A NFS can be installed on the same machine as Kubernetes outside Kubernetes.

## basic kubectl commands

`kubectl get nodes` - shows the known nodes
`kubectl version` - shows the version number
`kubectl get pod` - shows the pods
`kubectl get pod -o wide` - shows the pods with more information, including ip
`kubectl get services` - shows the services
`kubectl get all` - shows everything
`kubectl get all --all-namespaces` - shows everything

## deployments and pods

Pods are not created directly. Instead, deployments are being created.
`kubectl create deployment nginx-deployment --image=nginx` - create a deployment based on an image. Image will be downloaded from hub.docker.hub
`kubectl get deployment` - shows the deployments
`kubectl get replicaset` - shows the replicaset
`kubectl delete deployment [deployment_name]`

Deployments are being managed via kubectl. Deployments manage replicatesets which manage pods automatically.
`kubectl edit deployment nginx-deployment` - allows to edit the auto-generated config file of the specified deployment. Configuration will be automatically applied.

## Debugging pods

`kubectl logs [podname]`
`kubectl describe pod [podname]` - to get more info on a pod
`kubectl exec -it [podname] -- bin/bash`  - interactive terminal of that pod

## Analysing services

`kubectl describe service [servicename]`

## Configuration file

Configuration files exist eg for deployments and services.
It seems that kubernetes does not like underscores `_` in object names. Use `-` instead.

### Apply configuration file

`kubectl apply -f configuration_file.yaml` - apply a configuration file, also execute to apply changes.
`kubectl get deployment [deployment_name] - o yaml > configuration_file.yaml` - export config file, including status and other generated stuff (like timestamps).
`kubectl delete -f configuration_file.yaml` - delete objects mentioned in aa configuration file.

### 3 parts in a configuration file

- (header)
- metadata
- specification (spec)
- status
    - comparing specification vs actual status
    - source etcd

### Yaml

- Hint: Use Yaml Linter
- strict indentation
- store config file with your code / infrastructure as a code or separate git repo for config files
- deployments have a template in the spec, for the pod
- labels (like eg `app:nginx`) connect the information
- ports:
    - pods (inside the deployment) have a containerport
    - services have a ports i the specs
        - port: the external port
        - targetPort: the internal containerport

- secrets
    - don't store them in configuration file.
    - special configuration file
    - as values, store base64 encoded values
    - create base64 encoded values with `echo -n 'value' | base64`
    - `kubectl apply -f mongo-secret.yaml` to load/apply secret to kubernetes
    - `kubectl get secret` to show loaded secrets by their name.
    - adjust config file to reference secret file
    - the same secret can be used in different pods, eg as the sa password of the server, and as password used in connection string of client.

Yaml supports multiple files in one file, separated by a line with 3 minuses:

```YAML
---
```

Eg deployment and service in 1 file, because they belong together. Service references deployment.

- config_map allows to share configuration building blocks

## Publishing a service

LoadBalancer and nodeport allow to publish a port
check service configuation with `kubectl get service`
`minikube service mongo-express-service`

## Namespace

`kubectl get namespace`
Namespaces allow to put kubernetes objects in groups. The default namespace is `Default`.
Namespaces are useful to eg group different things (like logging, nginx, etc.), or in case different teams are using the Kubernetes cluster, or for different environments (dev/uat/prod) in one cluster, and recycle some components (like logging)

One namespace can access another, eg with a reference like `service.namespace`

`kubectl --namespace==namespace` The --namespace option allows to set the namespace. Also `-n` works.

Tool `kubens` allows to set a default namespace.

## Ingress

Ingress alllows to manage the access to a kubernetes cluster. 
A specific implementation for an ingress also needs to be selected - called Incress Controller. There are several (third party implementations)[https://bit.ly/3mJHVFc].
Moreover, an external loadbalancer/proxy server is needed to forward the traffic to the ingress controller.

`minikube addons enable ingress` starts an ingress controller.

`kubectl` also works for ingress objects.

To access an ingress controller based on a name (instead of IP adress), the hostfile of the machine can be edited.

ingress allows to forward subdomains or specific url paths to specific services.

ingress allows to configure TLS certificate. There are also specific tls secrets.

## Helm

Helm is a package manager for Kubernetes.

Eg image you want to deploy the elastic stack for logging. You could install this with all its details (StatefulSet, ConfigMap, User, Secret, Services) on your own.
The bundle of yaml files to deploy such a stack is called "helm charts". They are available in a helm repository.
Helm is available at https://helm.sh/. The client software itself is available on githug: https://github.com/helm/helm/releases
This works simialr to docker, eg helm search or searching e.g. at https://artifacthub.io/

Helm is also a templating engine. I.e. kubernetes.yaml templates can be defined, and base them on an external configuration.
Eg it takes values from values.yaml and put them into a  helm chart.  Values files can also be merged, eg standard values file and a customised values file.

Helm also has a chart repository called Tiller for release management. Since Tiller has to much rights, it was deleted again with Helm version 3. However, it is an illustration fot eh "infrastructre as code" concept.

## Volume

Requirements:

- A volume allows for storage that does not depend on the storage lifecycle.
- Since a pod can be started on any cluster, the volume must be accessible to any node.
- Storage needs to survive even if a cluster crashes.

Obviously, storage can be implemented in many ways, eg local storage, nfs storage, cloud storage, etc.
Kubernetes allows for different storage types.

Volumes are not in namespaces.

There are different volume types:

- Local volumes: Tied to specific node, do not survive crashes, ie not matching to two requirements.
- Remote volumes

### Persistent volume Claims (PVC)

Persistent volume claims allow to define the requirments of a service. A PVC will be mapped against a persistent volume. PVSs must be in the same namespace as the pod.

## Stateful Set

A stateful applications needs to store some data. Alternatively, there are also stateless applications.

Stateless applications are deployed using deployments. They can be easily replicated. 

Stateful applications are deployed using StatefulSets.

An example for a stateful application is a mysql database.

Eg mysql has advanced replication models, eg with a master instance, and worker instances.

Eg pod has its own data storage, also including the pod state (eg master vs worker).
Stateful set pods have a stateful set identifier. Also the corresponding service has a defined name.
The are numbered increasingly (eg mysql-0, mysql-1, mysql-2). For creation, the first one gets created first, for deletion, the last one gets deleted first - in order to protect the master.

Cloning and data synchronization as well as remote storage and back-up needs to be configured.

## Kubernetes Services

## Kubernetes Dashboard

For Kubernetes management and analysis, a dashboard is available

### Install Kubernetes dashboard

`kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml`
[Source](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

### Create a user

```powershell
kubectl apply -f ./admin-user.yaml
```

### Get a token for a kubernetes dashboard

```powershell
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | sls admin-user | ForEach-Object { $_ -Split '\s+' } | Select -First 1)
```

[Source](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)

[Dashboard URL](https://localhost:8443/)

### Access  via proxy

Create a proxy to connect to it with `kubectl proxy`
Connect to it: [URL](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

## Access Kubernetes dashboard with loadbalancer

See yml file, start with
`kubectl apply -f .\Kubernetes_configs\dashboard-loadbalancer.yml`
Connect to it: [URL](https://localhost:8443/)

## Sources

- [Kubernetes Tutorial for Beginners](https://www.youtube.com/watch?v=X48VuDVv0do)