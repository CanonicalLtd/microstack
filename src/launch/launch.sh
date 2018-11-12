#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Please specify a name for the server."
    exit 1
else
    SERVER=$1
fi

if [[ ! $(microstack.openstack keypair list | grep "| microstack |") ]]; then
    echo "creating keypair ($HOME/.ssh/id_microstack)"
    mkdir -p $HOME/.ssh
    chmod 700 $HOME/.ssh
    microstack.openstack keypair create microstack >> $HOME/.ssh/id_microstack
fi

echo "Launching instance ..."
microstack.openstack server create --flavor m1.tiny --image cirros --nic net-id=test --key-name microstack $SERVER

echo "Allocating floating ip ..."
ALLOCATED_FIP=`microstack.openstack floating ip create -f value -c floating_ip_address external`
microstack.openstack server add floating ip $SERVER $ALLOCATED_FIP

echo "Checking security groups ..."
SECGROUP_ID=`microstack.openstack security group list --project admin -f value -c ID`
if [[ ! $(microstack.openstack security group rule list | grep icmp | grep $SECGROUP_ID) ]]; then
    echo "Creating security group rule for ping."
    microstack.openstack security group rule create $SECGROUP_ID --proto icmp
fi

if [[ ! $(microstack.openstack security group rule list | grep tcp | grep $SECGROUP_ID) ]]; then
    echo "Creating security group rule for ssh."
    microstack.openstack security group rule create $SECGROUP_ID --proto tcp --dst-port 22
fi

echo "Waiting for server to launch."
while :; do
    if [[ $(microstack.openstack server list | grep $SERVER | grep ACTIVE) ]]; then
        echo "Launch complete!"
        microstack.openstack server list
        echo "Access your server with 'ssh -i $HOME/.ssh/id_microstack $ALLOCATED_FIP'"
        break
    fi
    if [[ $(microstack.openstack server list | grep $SERVER | grep ERROR) ]]; then
        microstack.openstack server list
        echo "Uh-oh. There was an error. See /var/snap/microstack/common/logs for details."
        break
    fi
done

echo "You can also visit the openstack dashboard at 'http://localhost/'"
