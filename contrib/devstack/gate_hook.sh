#!/bin/bash
set -xe

export PATH=$PATH:/usr/local/sbin:/usr/sbin

echo dirname $0
SCRIPTDIR=/opt/stack/new/nova-docker/contrib/devstack

# TODO : This should be removed once PATH contains sbin
#        https://review.openstack.org/#/c/91655/
sudo useradd -U -s /bin/bash -d /opt/stack/new -m stack || true
sudo useradd -U -s /bin/bash -m tempest || true

export INSTALLDIR=$BASE/new
bash -xe $SCRIPTDIR/prepare_devstack.sh

export DEVSTACK_GATE_VIRT_DRIVER=docker
export KEEP_LOCALRC=1

# Turn off tempest test suites
cat <<EOF >> $INSTALLDIR/tempest/etc/tempest.conf.sample
# The following settings have been turned off for nova-docker
[compute-feature-enabled]
resize=False
suspend=False
rescue=False

[service_available]
swift=False
ceilometer=False
cinder=False
EOF

export DEVSTACK_GATE_TEMPEST=1
export DEVSTACK_GATE_TEMPEST_FULL=1

$INSTALLDIR/devstack-gate/devstack-vm-gate.sh
