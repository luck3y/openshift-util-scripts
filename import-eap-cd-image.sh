#!/bin/bash -x
LPREFIX=jboss-eap-7-tech-preview
LNAME=eap-cd-openshift
PREFIX=openshift
NAME=eap-cd-openshift
VERSION="13.0"
VERSION_TAG="13"
PORT=5000

TEMPLATE_SRC=https://raw.githubusercontent.com/jboss-container-images/jboss-eap-7-openshift-image/eap-cd/templates/

oc login -u developer

# import the EAP CD imagestream
oc create -n $PREFIX -f ${TEMPLATE_SRC}/eap-cd-image-stream.json

# create the default secrets
oc create -n myproject -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/eap-app-secret.json
oc create -n myproject -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/eap7-app-secret.json
oc create -n myproject -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/sso-app-secret.json

# OCP seems to need a sleep here before we push to the docker registry
# for this to work you should have an appropriate image built in your local
# docker registry, example:
#
# $ docker image ls
# REPOSITORY                                                                   TAG                 IMAGE ID            CREATED             SIZE
# jboss-eap-7-tech-preview/eap-cd-openshift                                    13.0                deb960f72027        21 hours ago        1.89 GB
#
# The prefix/name:tag should match the declared variables at the top of this file.
#
sleep 5
AUTH=`oc whoami -t`
# get the ip for the internal registry.
CLUSTER_IP=`oc get -n default svc/docker-registry -o=yaml | grep clusterIP  | awk -F: '{print $2}'`

# tag and push the image (we could use oc image tag or oc import-image here too, but this seems to be more reliable.)
docker tag $LPREFIX/$LNAME:latest $LPREFIX/$LNAME:$VERSION
docker login -u developer -p $AUTH $CLUSTER_IP:$PORT

#jboss-eap-7-tech-preview/eap-cd-openshift:$VERSION
docker tag $LPREFIX/$LNAME:$VERSION $CLUSTER_IP:$PORT/$PREFIX/$NAME:$VERSION
docker tag $LPREFIX/$LNAME:$VERSION $CLUSTER_IP:$PORT/$PREFIX/$NAME:$VERSION_TAG
docker tag $LPREFIX/$LNAME:$VERSION $CLUSTER_IP:$PORT/$PREFIX/$NAME:latest
docker push $CLUSTER_IP:$PORT/$PREFIX/$NAME:$VERSION
docker push $CLUSTER_IP:$PORT/$PREFIX/$NAME:$VERSION_TAG
docker push $CLUSTER_IP:$PORT/$PREFIX/$NAME:latest
