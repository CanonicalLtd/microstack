#!/bin/bash
##############################################################################
#
# This is a "very basic" test script for Microstack. It will install
# the microstack snap on a vm, and dump you into a shell on the vm for
# troubleshooting.
#
# The multipass snap and the petname debian package must be installed
# on the host system in order to run this test.
#
##############################################################################

set -ex

UPGRADE_FROM="none"
DISTRO=18.04
MACHINE=$(petname)

# Make a vm
multipass launch --cpus 2 --mem 16G $DISTRO --name $MACHINE

# Install the snap
multipass copy-files microstack_rocky_amd64.snap $MACHINE:
multipass exec $MACHINE -- \
          sudo snap install --classic --dangerous microstack*.snap

# Drop the user into a snap shell, as root.
multipass exec $MACHINE -- \
          sudo snap run --shell microstack.launch

