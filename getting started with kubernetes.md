# getting started with kubernetes

## Kubernetes version
Using the one in docker, enable kubernetes in docker


## Install Kubernetes dashboard

`kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml`
[Source](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

Create a proxy to connect to it with `kubectl proxy`

Get token with
```powershell
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | sls admin-user | ForEach-Object { $_ -Split '\s+' } | Select -First 1)
```
[Source](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)

Connect to it: [URL]( http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

## Access Kubernetes dashboard with loadbalancer
See yml file, start with
`kubectl apply -f .\Kubernetes_configs\dashboard-loadbalancer.yml`


## Get helm chart packs from https://artifacthub.io/

## MariaDB

### Install MariaDB with Helm
https://bitnami.com/stack/mariadb/helm
`helm repo add bitnami https://charts.bitnami.com/bitnami`
`helm install my-release bitnami/mariadb`

### Helm output
```
NAME: my-release
LAST DEPLOYED: Sun Dec 20 16:20:25 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Please be patient while the chart is being deployed

Tip:

  Watch the deployment status using the command: kubectl get pods -w --namespace default -l release=my-release

Services:

  echo Primary: my-release-mariadb.default.svc.cluster.local:3306

Administrator credentials:

  Username: root
  Password : $(kubectl get secret --namespace default my-release-mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 --decode) -> uqSQ0aprbG

To connect to your database:

  1. Run a pod that you can use as a client:

      kubectl run my-release-mariadb-client --rm --tty -i --restart='Never' --image  docker.io/bitnami/mariadb:10.5.8-debian-10-r21 --namespace default --command -- bash

  2. To connect to primary service (read/write):

      mysql -h my-release-mariadb.default.svc.cluster.local -uroot -p my_database

To upgrade this helm chart:

  1. Obtain the password as described on the 'Administrator credentials' section and set the 'auth.rootPassword' parameter as shown below:

      ROOT_PASSWORD=$(kubectl get secret --namespace default my-release-mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)
      helm upgrade my-release bitnami/mariadb --set auth.rootPassword=$ROOT_PASSWORD
```


## MariaDb with own config file
see Kubernetes_configs/mariadb.yaml

`kubectl apply -f .\Kubernetes_configs\mariadb.yaml`


## Dashboard
Kubernetes has a built in dashboard. This can be usually access






## Using WSL + Ubuntu as Kubernetes host

set default
```PS
wsl --set-default-version 2
```

See
https://kubernetes.io/blog/2020/05/21/wsl-docker-kubernetes-on-the-windows-desktop/

install ubunto from appstore

open terminal > ubuntu terminal

Update Ubunu
```sh
# Update the repositories and list of the packages available
sudo apt update
# Update the system based on the packages installed > the "-y" will approve the change automatically
sudo apt upgrade -y
```

install go in ubunu
```sh
sudo apt-get install golang
PATH="$PATH:/home/uuser/go/bin"
```

install kind
`GO111MODULE="on" go get sigs.k8s.io/kind@v0.9.0 && kind create cluster`






## microK8s.io

install on wsl
>> microsoft store, ubuntu 20 latest

unix user name: uuser
password upw1


use ubunto from terminal

install microk8s on ubuntu: `sudo snap install microk8s --classic`\
==> klappt nicht

