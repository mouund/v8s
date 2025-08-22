#!/bin/bash

function help(){
    echo -e "USAGE: ./v8s.sh INTERFACE_NAME [--prune]
Using --prune will delete the machines before re creating them
In v8s.sh you can customize the components versions before running it 
eg:
export KUBEADM_VERSION=1.32
export RUNC_VERSION=1.3.0
export CONTAINERD_VERSION=2.1.4
export POD_CIDR="10.244.0.0/16"
export FLANNEL_CNI_VERSION=0.27.2
"
}
if [[ "$#" -lt 1 || "$1" == "-h" ]];then
    help
else

    TEMPLATE_DIR=$(pwd)/templates
    NIC=$1
    export NIC
    CURRENT_IP=$(ip a | grep -A 5 $NIC  | grep -w inet | awk '{print $2}' | cut -d "/" -f 1) 
    PREFIX_IP=$( echo ${CURRENT_IP} | cut -d "." -f 1-3)
    export MASTER_NAME="master-node01"
    export WORKER_NAME="worker-node01"
    export WORKER2_NAME="worker-node02"
    export MASTER_IP=${PREFIX_IP}.80
    export WORKER_IP=${PREFIX_IP}.81
    export WORKER2_IP=${PREFIX_IP}.82
    export KUBEADM_VERSION=1.32
    export RUNC_VERSION=1.3.0
    export CONTAINERD_VERSION=2.1.4
    export POD_CIDR="10.244.0.0/16"
    export WEAVE_CNI_VERSION=2.8.1



    if [[ "$2" == "--prune"  ]];then
        echo "Prune option passed, Destroying existing VMS"
        vagrant destroy --force
    fi
    echo -e "Genrerating conf from template..."
    envsubst < "${TEMPLATE_DIR}/nodes.yaml.template" > "nodes.yaml"
    envsubst < "${TEMPLATE_DIR}/inventory.template" > "inventory"
    envsubst < "${TEMPLATE_DIR}/vars.yaml.template" > "group_vars/all/vars.yaml"


    echo -e "Adding machines to hosts file"
    if [[ !  $(sudo  grep ${MASTER_NAME}  /etc/hosts) ]];then
        echo "${MASTER_IP} ${MASTER_NAME}" | sudo tee -a /etc/hosts
    fi
    if [[ !  $(sudo  grep ${WORKER_NAME} /etc/hosts) ]];then
        echo "${WORKER_IP} ${WORKER_NAME}" | sudo tee -a /etc/hosts
    fi
    if [[ !  $(sudo  grep ${WORKER2_NAME} /etc/hosts) ]];then
        echo "${WORKER2_IP} ${WORKER2_NAME}" | sudo tee -a /etc/hosts
    fi

    if [ -f $HOME/.ssh/known_hosts ];then
        echo -e "Cleaning up ssh keys from previously created hosts"
        ssh-keygen -R ${MASTER_NAME}
        ssh-keygen -R ${WORKER_NAME}
        ssh-keygen -R ${WORKER2_NAME}
        ssh-keygen -R ${MASTER_IP}
        ssh-keygen -R ${WORKER_IP}
        ssh-keygen -R ${WORKER2_IP}
    fi

    echo -e "Using IPs for nodes: Master $MASTER_IP Wokers: $WORKER_IP , $WORKER2_IP"
    echo -e "Starting VM creation..."
    vagrant up
    echo -e "Waiting for setup to be complete.."
    sleep 30
    echo -e "Starting configuration playbook, if it fails, you can relaunch it via $ ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook setup.yaml -i inventory .."
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook setup.yaml -i inventory

fi



