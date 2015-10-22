#!/bin/sh

GIT_BASE='git://git.openstack.org'

REPOS='
openstack-dev/devstack
openstack/cinder
openstack/glance
openstack/heat
openstack/horizon
openstack/ironic
openstack/keystone
openstack/neutron
openstack/neutron-fwaas
openstack/neutron-lbaas
openstack/neutron-vpnaas
openstack/nova
openstack/swift
openstack/requirements
openstack/tempest
openstack/tempest-lib
openstack/python-cinderclient
openstack/python-glanceclient
openstack/python-heatclient
openstack/python-ironicclient
openstack/keystoneauth
openstack/python-keystoneclient
openstack/python-neutronclient
openstack/python-novaclient
openstack/python-swiftclient
openstack/python-openstackclient
openstack/cliff
openstack/futurist
openstack/debtcollector
openstack/automaton
openstack/oslo.cache
openstack/oslo.concurrency
openstack/oslo.config
openstack/oslo.context
openstack/oslo.db
openstack/oslo.i18n
openstack/oslo.log
openstack/oslo.messaging
openstack/oslo.middleware
openstack/oslo.policy
openstack/oslo.reports
openstack/oslo.rootwrap
openstack/oslo.serialization
openstack/oslo.service
openstack/oslo.utils
openstack/oslo.versionedobjects
openstack/oslo.vmware
openstack/pycadf
openstack/stevedore
openstack/taskflow
openstack/tooz
openstack/glance_store
openstack/heat-cfntools
openstack/heat-templates
openstack/django_openstack_auth
openstack/keystonemiddleware
openstack/swift3
openstack/ceilometermiddleware
openstack/os-brick
openstack/ironic-lib
openstack/dib-utils
openstack/os-apply-config
openstack/os-collect-config
openstack/os-refresh-config
openstack/ironic-python-agent
'

for r in $REPOS ; do
  if [ -x repos/$r.git ] ; then
    pushd repos/$r.git
    git pull --rebase
    popd
  else
    git clone $GIT_BASE/$r.git repos/$r.git
  fi
done
