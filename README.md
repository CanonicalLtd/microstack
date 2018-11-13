# openstack

[![Snap Status](https://build.snapcraft.io/badge/CanonicalLtd/openstack.svg)](https://build.snapcraft.io/user/CanonicalLtd/openstack)

OpenStack in a snap that you can run locally on a single machine!

`openstack` currently provides Nova, Keystone, Glance, Horizon and Neutron OpenStack services.

## Installation

`openstack` is frequently updated to provide the latest stable updates of the most recent OpenStack release.  The quickest was to get started is to install directly from the snap store.  You can install `openstack` using:

```
sudo snap install openstack --classic --edge
```


## Accessing OpenStack

`openstack` provides a pre-configured OpenStack CLI to access the local OpenStack deployment; its namespaced using the `openstack` prefix:

```
openstack.openstack server list
```

You can setup this command as an alias for `openstack` if you wish (removing the need for the `openstack.` prefix):

```
sudo snap alias openstack.openstack openstack
```

Alternatively you can access the Horizon OpenStack dashboard on `http://127.0.0.1` with the following credentials:

```
username: admin
password: keystone
```

## Booting and accessing an instance

`openstack` comes preconfigured with networking and images so you can get starting using OpenStack as soon as `openstack` is installed; to boot an instance:

```
openstack.openstack server create --flavor m1.small --nic net-id=test --image cirros my-openstack-server
```

To access the instance, you'll need to assign it a floating IP address:

```
ALLOCATED_FIP=`openstack.openstack floating ip create -f value -c floating_ip_address external`
openstack.openstack server add floating ip my-openstack-server $ALLOCATED_FIP
```

and as you would expect, `openstack` is just like a full OpenStack Cloud and does not allow ingress access to the instance by default, so next enable SSH and ping access to the instance:

```
SECGROUP_ID=`openstack.openstack security group list --project admin -f value -c ID`
openstack.openstack security group rule create $SECGROUP_ID --proto tcp --remote-ip 0.0.0.0/0 --dst-port 22
openstack.openstack security group rule create $SECGROUP_ID --proto icmp --remote-ip 0.0.0.0/0
```

once this is complete you should be able to SSH to the instance:

```
ssh cirros@$ALLOCATED_FIP
```

Happy `openstack`ing!

## Stopping and starting openstack

You may wish to temporarily shutdown openstack when not in use without un-installing it.

`openstack` can be shutdown using:

```
sudo snap disable openstack
```

and re-enabled latest using:

```
sudo snap enable openstack
```
