#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Please specify a name for the server."
    exit 1
else
    SERVER=$1
fi

if [[ ! $(openstack keypair list | grep "| microstack |") ]]; then
    echo "creating keypair ($HOME/.ssh/id_microstack)"
    mkdir -p $HOME/.ssh
    chmod 700 $HOME/.ssh
    openstack keypair create microstack >> $HOME/.ssh/id_microstack
    chmod 600 $HOME/.ssh/id_microstack
fi

echo "Launching instance ..."
openstack server create --flavor m1.tiny --image cirros --nic net-id=test --key-name microstack $SERVER

echo "Checking security groups ..."
SECGROUP_ID=`openstack security group list --project admin -f value -c ID`
if [[ ! $(openstack security group rule list | grep icmp | grep $SECGROUP_ID) ]]; then
    echo "Creating security group rule for ping."
    openstack security group rule create $SECGROUP_ID --proto icmp
fi

if [[ ! $(openstack security group rule list | grep tcp | grep $SECGROUP_ID) ]]; then
    echo "Creating security group rule for ssh."
    openstack security group rule create $SECGROUP_ID --proto tcp --dst-port 22
fi

TRIES=0
while [[ $(openstack server list | grep $SERVER | grep ERROR) ]]; do
    TRIES=$(($TRIES + 1))
    if test $TRIES -gt 3; then
        break
    fi
    echo "I ran into an issue launching an instance. Retrying ... (try $TRIES of 3)"
    openstack server delete $SERVER
    openstack server create --flavor m1.tiny --image cirros --nic net-id=test --key-name microstack $SERVER
    while [[ $(openstack server list | grep $SERVER | grep BUILD) ]]; do
        sleep 1;
    done
done

echo "Allocating floating ip ..."
ALLOCATED_FIP=`openstack floating ip create -f value -c floating_ip_address external`
openstack server add floating ip $SERVER $ALLOCATED_FIP

echo "Waiting for server to become ACTIVE."
while :; do
    if [[ $(openstack server list | grep $SERVER | grep ACTIVE) ]]; then
        openstack server list
        echo "Access your server with 'ssh -i $HOME/.ssh/id_microstack cirros@$ALLOCATED_FIP'"
        break
    fi
    if [[ $(openstack server list | grep $SERVER | grep ERROR) ]]; then
        openstack server list
        echo "Uh-oh. There was an error. See /var/snap/microstack/common/logs for details."
        break
    fi
done

echo "You can also visit the openstack dashboard at 'http://localhost/'"
