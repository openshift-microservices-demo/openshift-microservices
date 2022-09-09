#!/bin/bash

# Define Namespace variable
NAMESPACE=$1

# Check if the namespace already exists
if oc get namespace -o json | jq -r ".items[].metadata.name" | grep $NAMESPACE; then \
  echo "The Namespace $NAMESPACE already exists" 
else
# The above code gets superceded by the 'oc' command

# Create the Namespace
echo "apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}" | oc apply -f -
# Finish Namespace execution
fi
#
# Modify privileges for the defaut service account in scc. This step needs to be reviewed as the gives the service account too much privileges.
oc adm policy add-scc-to-user privileged -z default -n $1
#
# Change into the new Namespace
oc project ${NAMESPACE}
#
# Deploy the all-in-one application stack
oc apply -f all-in-one.yaml
#
# Expose the frontend service
oc expose service frontend
#
# Get the url for the website
echo "The url for the shop is http://{oc get route | cut -d" " -f4}
