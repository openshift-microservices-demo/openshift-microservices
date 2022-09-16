#!/bin/bash

# Remove the export variable if it already exists, set the new variable, then export it.
unset NAMESPACE
NAMESPACE=$1
export NAMESPACE
#
# Check if the namespace already exists
if oc get namespace -o json | jq -r ".items[].metadata.name" | grep $NAMESPACE; then \
  echo "The Namespace $NAMESPACE already exists" 
else
#
# Create the Namespace
echo "apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}" | oc apply -f -
fi
#
# Modify privileges for the defaut service account in scc. This step needs to be reviewed as the gives the service account too much privileges.
oc adm policy add-scc-to-user privileged -z default -n $1
#
# Change into the new Namespace
oc project ${NAMESPACE}
#
# Deploy the all-in-one application stack
oc apply -f ${PWD}/all-in-one.yaml
#
# **Need to create logic to monitor the website until the service is up and running**
#
# Expose the frontend service
oc expose svc frontend --name=$1-route --hostname=$2.pebcac.org
#
# Get the url for the website
ROUTE=`oc get route | cut -d" " -f4`
#for i in `curl -kvv $ROUTE`; do grep "HTTP\/1.1 200" 
echo "The shop url is "http://${ROUTE}""
#
# Apply a quota to the namespace
oc apply -f ${PWD}/boutique-quota.yaml
# 
# Apply autoscaling for the frontend service
oc apply -f ${PWD}/frontend-hpa.yaml


