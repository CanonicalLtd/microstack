# Contributing

## Building Microstack

Currently, you must build microstack on a machine running Ubuntu 16.04 Xenial. A goal of the project is to expand this to other environments, but for now, there are some Debian packages specific to Xenial required in snapcraft.yaml.

To build microstack, do the following:

```
export PATH=/snap/bin:$PATH
sudo snap install --classic snapcraft
git clone git@github.com:CanonicalLtd/microstack.git
cd microstack
snapcraft
```

Optionally, if you want to keep the system clean of dependencies, you can install lxd and do a cleanbuild (note that the apt packaged version of lxd in Xenial won't work -- you want to use the snap).

```
sudo snap install --classic lxd
sudo usermod -aG lxd <your username>
newgrp lxd
lxd init  # Going with the defaults is fine
```

Then replace `snapcraft` above with `snapcraft cleanbuild`

## How the Code is Structured

Microstack is a Snap, which means that, after it has been built, it contains all the code and dependencies that it needs, destined to be mounted in a read only file system on a host.

Before contributing, you probably want to read the general Snap Documentation here: https://docs.snapcraft.io/snap-documentation/3781

There are several important files and directories in microstack, some of which are like those in other snaps, some of which are unique to microstack:

### `./snapcraft.yaml`

This is the core of the snap. You'll want to start here when it comes to adding code. And you may not need to leave this file at all.

### `./snap-overlay`

Any files you add to snap-overlay will get written to the corresponding place in the file hierarchy under `/snap/microstack/common/`. Drop files in here if you want to insert a file or directory that does not come bundled by default with the Openstack source tarballs.

### `./snap-overlay/snap-openstack.yaml`

This is a yaml file unique to Snaps created by the Openstack team at Canonical. It creates a command called `snap-openstack`, which wraps Openstack daemons and scripts.

Documentation for this helper lives here: https://github.com/openstack/snap.openstack

It's installed by the openstack-projects part.

If you're adding an Openstack component to the snap, you may find it useful to take a look at the parts and apps that take advantage of snap-openstack, and add your own section to `snap-openstack.yaml`.

### Filing Bug and Submitting Pull Requests

We track bugs and features on launchpad, at https://bugs.launchpad.net/microstack

To submit a bugfix or feature, please fork the github repo, and create a pull request against it. The microstackers team will see it and review your code.
