# Installation of Kubernetes k3s on a baremetal machine

## Basic setup of baremetal pcs

OS Ubuntu 18.04 LTS - Server
- ISO with balenaEtcher to Stick
- Installation

## Install OpenSSH to be able to access the server

```
sudo apt update
sudo apt install openssh-server
sudo systemctl start ssh
```

### Later - authentication with SSH Key instead of password

SSH Key generated
Public Key stored at Github, following https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
Ubuntu received GitHub 
SSH activated
TODO - reconfigure both PCs to use SSH key, read about SSH key authentication, see C:\Users\%USERNAME%\.ssh


## installation of k3s

To install k3s, pick one of the following commands, either for master or agent:

```
# on master
curl -sfL https://get.k3s.io -o k3s
sh ./k3s --node-name [master_hostname] --disable servicelb --disable traefik --disable local-storage
sudo cat /var/lib/rancher/k3s/server/node-token # outputs token

# on agent(s)
curl -sfL https://get.k3s.io -o k3s
K3S_URL=https://[master_hostname]:6443 K3S_TOKEN=[k3s_token] sh ./k3s --node-name [agent_hostname]
```

Also see [Source](https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/) for more information, or check out the [config options](https://rancher.com/docs/k3s/latest/en/installation/install-options/agent-config/).


## Configure kubectl to connect to cluster

Get kubeconfig from cluster: `sudo cat /etc/rancher/k3s/k3s.yaml`.

Copy the kubeconfig content to local `{HOME}/.kube/config` and adjust the format.

Configure kubectl to use the cluster and check whether the nodes are visible.
```
kubectl config use-context [clustername]
kubectl get nodes # yey!
```


## MetallLb

[MetalLb](https://metallb.universe.tf/) installs a loadbalancer for baremetal installations.
Follow the [installation instructions](https://metallb.universe.tf/installation/), section "by manifest".

Download the 2 mentioned yaml files. In the `metallb.yaml`, adjust the IP ranges.

Apply the two files with
```
kubectl apply -f namespace.yaml
kubectl apply -f metallb.yaml
```

Create a secret for metalLb on a linux command line with `openssl rand -base64 128`

Configure the encrypted communication of MetalLb with:
```
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
```

After the installation of metalLb, it is possible to install loadbalancer and access kubernetes services from the outside.


## Install the k3s dashboard

### Install the k3s dashboard itself
The installation of the k3s dashboard is well [documented](https://rancher.com/docs/k3s/latest/en/installation/kube-dashboard/):

```bash
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
sudo k3s kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
```

### Install the dashboard user

Configure an admin user. For sure, the security can be further enhanced.
See `dashboard.user.yaml`([Source](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md))

```
kubectl apply -f dashboard.user.yaml
```

### Install the dashboard loadbalancer

Install the dashboard loadbalancer and verify thepods and loadbalancer
```
kubectl apply -f dashboard-loadbalancer.yml
kubectl get all --all-namespaces
```

Get token with

```powershell
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | sls admin-user | ForEach-Object { $_ -Split '\s+' } | Select -First 1)
```
[Source](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)

Access the dashboard. 

## NFS

### Install a NFS server on a node outside Kubernetes

Install a Network File Server on a node (source)[https://vitux.com/install-nfs-server-and-client-on-ubuntu/] as a basis for persistent volumes.

```bash
sudo apt-get update
sudo apt install nfs-kernel-server
sudo mkdir -p /mnt/sharedfolder
sudo chown nobody:nogroup /mnt/sharedfolder
sudo chmod 777 /mnt/sharedfolder
```

and use no_root_squash (!!) - https://stackoverflow.com/questions/34878574/kubernetes-mysql-chown-operation-not-permitted

edit 
`sudo nano /etc/exports`
add 
```
/mnt/sharedfolder   *(rw,async,no_root_squash)
```

Export the shared directory and restart the server
```
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
```


### Kubernetes NFS Provisioner

Install a NFS provisioner in Kubernetes, accessing the NFS server
```
kubectl apply -f nfs-provisioner.yaml
```

## Install actual services

```
kubectl apply -f mariadb.yaml
kubectl apply -f shared-volume.yaml
kubectl apply -f mssql.yaml
kubectl apply -f jenkins.yaml
kubectl apply -f jenkins_agent_python.yaml
```
