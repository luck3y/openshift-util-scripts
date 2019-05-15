#!/bin/bash -x
LPREFIX=jboss-eap-7-tech-preview
LNAME=eap-cd-openshift
NAMESPACE=openshift
NAME=eap-cd-openshift
VERSION="15.0"
VERSION_TAG="15"
PORT=5000

TEMPLATE_SRC=https://raw.githubusercontent.com/jboss-container-images/jboss-eap-7-openshift-image/eap-cd-dev/templates/

oc login -u developer

# import the EAP CD imagestream
curl ${TEMPLATE_SRC}/eap-cd-image-stream.json | sed 's|registry.access.redhat.com/jboss-eap-7-tech-preview|openshift|g' | sed 's|registry.redhat.io/jboss-eap-7-tech-preview|openshift|g' | oc replace --force -n ${NAMESPACE} -f -

# create the default secrets
oc replace --force -n myproject -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/eap-app-secret.json
oc replace --force -n myproject -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/eap7-app-secret.json
oc replace --force -n myproject -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/sso-app-secret.json

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
docker tag $LPREFIX/$LNAME:$VERSION $CLUSTER_IP:$PORT/${NAMESPACE}/$NAME:$VERSION
docker tag $LPREFIX/$LNAME:$VERSION $CLUSTER_IP:$PORT/${NAMESPACE}/$NAME:$VERSION_TAG
docker tag $LPREFIX/$LNAME:$VERSION $CLUSTER_IP:$PORT/${NAMESPACE}/$NAME:latest
docker push $CLUSTER_IP:$PORT/${NAMESPACE}/$NAME:$VERSION
docker push $CLUSTER_IP:$PORT/${NAMESPACE}/$NAME:$VERSION_TAG
docker push $CLUSTER_IP:$PORT/${NAMESPACE}/$NAME:latest
#!/bin/bash -x
NAMESPACE=openshift

for resource in \
  eap-cd-amq-persistent-s2i.json \
  eap-cd-amq-s2i.json \
  eap-cd-basic-s2i.json \
  eap-cd-https-s2i.json \
  eap-cd-mongodb-persistent-s2i.json \
  eap-cd-mongodb-s2i.json \
  eap-cd-mysql-persistent-s2i.json \
  eap-cd-mysql-s2i.json \
  eap-cd-postgresql-persistent-s2i.json \
  eap-cd-postgresql-s2i.json \
  eap-cd-third-party-db-s2i.json \
  eap-cd-tx-recovery-s2i.json \
  eap-cd-sso-s2i.json
do
 oc replace -n ${NAMESPACE} --force -f ${TEMPLATE_SRC}/${resource}
done

