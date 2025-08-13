
# v8s | e2e K8s cluster creation using Vagrant Ansible & Kubeadm in one command

## What is it ?

This project will deploy a "real" K8s cluster with one controleplane and two workers hosted in ubuntu VMs in Vbox. 
Really handy to test some K8s related stuff.
Technically:
CNI: Flannel
Container runtime: runc
Container engine: containerd 

## How to use it

Clone the project

```bash
  git clone https://github.com/mouund/v8s
  cd v8s
```
Customize the parameters in v8s.sh according to your needs, by default

Kubeadm version 1.32
Runc version 1.3.0
containerd version 2.1.4
Pod CIDR for CNI 10.244.0.0/16
Flannel version .27.2

Get the name of the network interface you want to use to connect to the VMs, it will be bridged.

```bash
  ip link
```

Now start the script

```bash
  ./v8s.s INTERFACE [PRUNE_OPTION]
```

It will run vagrant to create the VMs. 
Then an ansible playbook will configure the nodes

The final setup will be 
1 controleplane
2 worker nodes

The final playbook output will be the nodes (workers might not be ready, no worries let them some time)

To use it form your machine, get th econfig file
```
$ cp root@master-node01:/root/.kube/config ~/.kube/config2 
```
```
$ kubectl get pods --kubeconfig=/home/moun/.kube/config2
OR 
$ export KUBECONFIG=/home/moun/.kube/config2
```
Use it :D 

```
$ k run nginx --image nginx
pod/nginx created

$ k get pods
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          44s

```
```
k get nodes
NAME            STATUS   ROLES           AGE   VERSION
master-node01   Ready    control-plane   15m   v1.32.7
worker-node01   Ready    <none>          14m   v1.32.7
worker-node02   Ready    <none>          14m   v1.32.7

```

## References

* https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

* https://github.com/opencontainers/runc

* https://github.com/opencontainers/runc

* https://github.com/flannel-io/

