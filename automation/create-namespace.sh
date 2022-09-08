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

# Change into the new Namespace
oc project ${NAMESPACE}