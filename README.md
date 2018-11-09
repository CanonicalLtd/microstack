# microstack

[![Snap Status](https://build.snapcraft.io/badge/CanonicalLtd/microstack.svg)](https://build.snapcraft.io/user/CanonicalLtd/microstack)

OpenStack in a snap that you can run locally.

## User Guide

`microstack` is frequently updated to provide the latest stable updates of the most recent OpenStack release.  The quickest was to get started is to install directly from the snap store.  You can install `microstack` using:

```
sudo snap install microstack --classic --edge
```

Once the snap is installed, you need to perform a one off configuration process:

```
sudo microstack.configure
```

This will initialize all OpenStack services, configure access, network and an image to use on the local OpenStack deployment.

## Accessing OpenStack

`microstack` provides a pre-configured OpenStack CLI to access the local OpenStack deployment; its namespace using the `microstack` prefix:

```
microstack.openstack server list
```

## Stopping and starting microstack

You may wish to temporarily shutdown microstack when not in use without un-installing it.

microstack can be shutdown using:

```
sudo snap disable microstack
```

and re-enabled latest using:

```
sudo snap enable microstack
```
