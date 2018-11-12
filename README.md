# microstack

[![Snap Status](https://build.snapcraft.io/badge/CanonicalLtd/microstack.svg)](https://build.snapcraft.io/user/CanonicalLtd/microstack)

OpenStack in a snap that you can run locally on a single machine!

`microstack` currently provides Nova, Keystone, Glance, Horizon and Neutron OpenStack services.

## Installation

`microstack` is frequently updated to provide the latest stable updates of the most recent OpenStack release.  The quickest was to get started is to install directly from the snap store.  You can install `microstack` using:

```
sudo snap install microstack --classic --edge
```


## Accessing OpenStack

`microstack` provides a pre-configured OpenStack CLI to access the local OpenStack deployment; its namespaced using the `microstack` prefix:

```
microstack.openstack server list
```

You can setup this command as an alias for `openstack` if you wish (removing the need for the `microstack.` prefix):

```
sudo snap alias microstack.openstack openstack
```

Alternatively you can access the Horizon OpenStack dashboard on `http://127.0.0.1` with the following credentials:

```
username: admin
password: keystone
```

## Booting and accessing an instance

`microstack` comes preconfigured with networking and images so you can get starting using OpenStack as soon as `microstack` is installed; to boot an instance:

```
microstack.openstack server create --flavor m1.small --nic net-id=test --image cirros my-microstack-server
```

To access the instance, you'll need to assign it a floating IP address:

```
ALLOCATED_FIP=`microstack.openstack floating ip create -f value -c floating_ip_address external`
microstack.openstack server add floating ip my-microstack-server $ALLOCATED_FIP
```

and as you would expect, `microstack` is just like a full OpenStack Cloud and does not allow ingress access to the instance by default, so next enable SSH and ping access to the instance:

```
SECGROUP_ID=`microstack.openstack security group list --project admin -f value -c ID`
microstack.openstack security group rule create $SECGROUP_ID --proto tcp --remote-ip 0.0.0.0/0 --dst-port 22
microstack.openstack security group rule create $SECGROUP_ID --proto icmp --remote-ip 0.0.0.0/0
```

once this is complete you should be able to SSH to the instance:

```
ssh cirros@$ALLOCATED_FIP
```

Happy `microstack`ing!

## Stopping and starting microstack

You may wish to temporarily shutdown microstack when not in use without un-installing it.

`microstack` can be shutdown using:

```
sudo snap disable microstack
```

and re-enabled latest using:

```
sudo snap enable microstack
```
