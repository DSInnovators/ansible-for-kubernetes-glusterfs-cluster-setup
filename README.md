# IEIMS Server Setup

IEIMS server contains two major component:
- Kubernetes (k8s) cluster
- Glusterfs (network storage) cluster 

This document covers the necessary steps to install above components into any number of servers from scratch.  

### Pre-requisites of IEIMS server

After getting the physical or virtual machines (at least two), we need to prepare the servers for installing IEIMS cluster by ensuring following steps:

Root password should be set on every machine. 

    sudo passwd root

Ensure root ssh is allowed on every machines (if not already allowed) by appending following line into `/etc/ssh/sshd_config`

    PermitRootLogin yes

Remember to restart the ssh service after making the above change.

    sudo service ssh restart
    
    sudo service sshd restart

Ensure password less ssh login from master to all worker nodes (both for current user and root user).

    ssh-keygen (if rsa key is already not generated on master)

    ssh-copy-id -i ~/.ssh/id_rsa user@host

Just for readibility purpose, you can always alter each of the node's `/etc/hosts` file in-order to add some reasonable naming against each local IP address.


### Setting up IEIMS Server

Once you established the initial communication channel among the servers by following pre-requisite steps, you are ready to setup the IEIMS server. In-order to setup the IEIMS server, you need to install ansible on your local machine:

    sudo apt update

    sudo apt install ansible

Now let's make some changes on the available ansible inventory file on `inventory/*.ini` with our server ip addresses.

Once we are done with modifing ansible inventory, then ensure password less ssh login from current local machine to all IEIMS servers.

    ssh-keygen (if rsa key is already not generated on master)

    ssh-copy-id -i ~/.ssh/id_rsa emis@host

Let's run the following command to install all necessary component on the provided servers now:

    ansible-playbook playbook.yaml -i inventory/qa.ini --user=emis --extra-vars "ansible_become_pass=yourPassword glusterfs_nodes='glusternode1 glusternode2'"

Great! Above step should install all necessary components into your server machines and bring up live kubernates and glusterfs cluster infrastructure.

Execute following steps on master node to make the gluster fs cluster ready for you application stack.

Initiate the cluster by running following command:

    heketi-cli cluster create

Add worker nodes into the glusterfs cluster:

    heketi-cli node add --zone=1 --cluster=<cluster-id> --management-host-name=<node-dns-name> --storage-host-name=<node-local-ip>

Example:

    heketi-cli node add --zone=1 --cluster=8868d0e6a35c328f5af396e449b06534 --management-host-name=emis-2 --storage-host-name=10.0.0.42

Follow the above step for each of the glusterfs worker nodes. Once done adding all nodes, check the cluster status by:

    heketi-cli cluster info <cluster-id>

Finally, add additional storage device for each of the glusterfs nodes:

    heketi-cli device add --name=/dev/sdb --node=<node-id>

Run `lsblk` on each of the node to get available list of devices on each node.
