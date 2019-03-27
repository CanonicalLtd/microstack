#!/bin/bash

set -ex

# Dependencies. TODO: move these into a testing harness
command -v multipass > /dev/null || (echo "Please install multipass."; exit 1);
command -v petname > /dev/null || (echo "Please install petname."; exit 1);
if [ ! -f microstack_rocky_amd64.snap ]; then
   echo "microstack_rocky_amd64.snap not found."
   echo "Please run snapcraft before executing the tests."
   exit 1
fi

MACHINE=$(petname)
DISTRO=18.04

# Launch a machine and copy the snap to it.
multipass launch --cpus 2 --mem 16G $DISTRO --name $MACHINE
multipass copy-files microstack_rocky_amd64.snap $MACHINE:
multipass exec $MACHINE -- \
          sudo snap install --classic --dangerous microstack*.snap

# Run microstack.launch and wait for it to complete.
multipass exec $MACHINE -- /snap/bin/microstack.launch breakfast
IP=$(multipass exec $MACHINE -- /snap/bin/microstack.openstack server list | grep breakfast | cut -d" " -f9)
echo "Waiting for ping..."
PINGS=1
MAX_PINGS=20
until multipass exec $MACHINE -- ping -c 1 $IP &>/dev/null; do
    PINGS=$(($PINGS + 1));
    if test $PINGS -gt $MAX_PINGS; then
        break
    fi
done;

# Verify that we can ping the machine, and ping from the machine to
# canonical.com (91.189.94.250).
# TODO no longer hard code canonical.com's IP address.
multipass exec $MACHINE -- ping -c 1 $IP;
sleep 5; # Sometimes the machine is still not quite ready. TODO better wait.
multipass exec $MACHINE -- \
          ssh -oStrictHostKeyChecking=no -i .ssh/id_microstack cirros@$IP -- \
          ping -c 1 91.189.94.250

# Cleanup
unset IP
echo "Completed tests. Tearing down $MACHINE."
multipass stop $MACHINE
multipass purge  # This is a little bit rude to do, but we assume that
                 # we can beat up on the test machine a bit.

