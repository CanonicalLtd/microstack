#!/bin/bash
##############################################################################
#
# This is a "basic" test script for Microstack. It will install the
# microstack snap, spin up a test instance, and verify that the test
# instance is accessible, and can access the Internet.
#
# The multipass snap and the petname debian package must be installed
# on the host system in order to run this test.
#
# The basic test accepts two command line arguments:
#
# -u <channel> # First installs a released snap from the named
#              # channel, in order to test basic upgrade functionality.
#
# -d <distro>  # Specifies the distro of the multipass vm.
#
##############################################################################

# Configuration and checks
set -ex

UPGRADE_FROM="none"
DISTRO=18.04

while getopts u:d: option
do
    case "${option}"
    in
        u) UPGRADE_FROM=${OPTARG};;
        d) DISTRO=${OPTARG};;
    esac
done

command -v multipass > /dev/null || (echo "Please install multipass."; exit 1);
command -v petname > /dev/null || (echo "Please install petname."; exit 1);
if [ ! -f microstack_rocky_amd64.snap ]; then
   echo "microstack_rocky_amd64.snap not found."
   echo "Please run snapcraft before executing the tests."
   exit 1
fi

MACHINE=$(petname)

# Setup
echo "++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "++    Starting tests on $MACHINE.               ++"
echo "++      Distro: $DISTRO                         ++"
echo "++      Upgrade from: $UPGRADE_FROM             ++"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++"

# Launch a machine and copy the snap to it.
multipass launch --cpus 2 --mem 16G $DISTRO --name $MACHINE
multipass copy-files microstack_rocky_amd64.snap $MACHINE:

# Possibly install a release of the snap before running a test.
if [ "${UPGRADE_FROM}" != "none" ]; then
    multipass exec $MACHINE -- sudo snap install --classic \
              --${UPGRADE_FROM} microstack
fi

# Install the snap under test
multipass exec $MACHINE -- \
          sudo snap install --classic --dangerous microstack*.snap
# Comment out the above and uncomment below to install the version of
# the snap from the store.
# TODO: add this as a flag.
#multipass exec $MACHINE -- \
#          sudo snap install --classic --edge microstack

# Run microstack.launch
multipass exec $MACHINE -- /snap/bin/microstack.launch breakfast

# Verify that endpoints are setup correctly
# List of endpoints should contain 10.20.20.1
if ! multipass exec $MACHINE -- /snap/bin/microstack.openstack endpoint list | grep "10.20.20.1"; then
    echo "Endpoints are not set to 10.20.20.1!";
    exit 1;
fi
# List of endpoints should not contain localhost
if multipass exec $MACHINE -- /snap/bin/microstack.openstack endpoint list | grep "localhost"; then
    echo "Endpoints are not set to 10.20.20.1!";
    exit 1;
fi


# Verify that microstack.launch completed
IP=$(multipass exec $MACHINE -- /snap/bin/microstack.openstack server list | grep breakfast | cut -d" " -f9)
echo "Waiting for ping..."
PINGS=1
MAX_PINGS=20
until multipass exec $MACHINE -- ping -c 1 $IP &>/dev/null; do
    PINGS=$(($PINGS + 1));
    if test $PINGS -gt $MAX_PINGS; then
        echo "Unable to ping machine!";
        exit 1;
    fi
done;

ATTEMPTS=1
MAX_ATTEMPTS=20
until multipass exec $MACHINE -- \
          ssh -oStrictHostKeyChecking=no -i .ssh/id_microstack cirros@$IP -- \
          ping -c 1 91.189.94.250; do
    ATTEMPTS=$(($ATTEMPTS + 1));
    if test $ATTEMPTS -gt $MAX_ATTEMPTS; then
        echo "Unable to access Internet from machine!";
        exit 1;
    fi
    sleep 5
done;

# Cleanup
unset IP
echo "++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "++   Completed tests. Tearing down $MACHINE.    ++"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++"
multipass stop $MACHINE
multipass delete $MACHINE
multipass purge  # This is a little bit rude to do, but we assume that
                 # we can beat up on the test machine a bit.
