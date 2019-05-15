#!/bin/bash -x
#
# this script is intended to be a quick and easy way to configure OCP using oc cluster up
#

# start cluster, if not already started
# oc cluster up 
oc login -u system:admin

# give the developer user cluster-admin so we can import images
oc adm policy add-cluster-role-to-user cluster-admin developer
oc login -u developer

# expose the internal docker registry so we can push to it.
oc create route edge --service=docker-registry -n default

