#!/bin/bash
#set -x

source env.txt

LOGINRESPONSE=`curl -s "https://${URL}/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"'${USER}'","password":"'${PASSWORD}'"}' --insecure`

LOGINTOKEN=`echo $LOGINRESPONSE | jq -r .token`

APIRESPONSE=`curl -s "https://${URL}/v3/token" -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure`

APITOKEN=`echo $APIRESPONSE | jq -r .token`

echo "Please copy the following token:"
echo -e "${APITOKEN}\n"

## Create Custom Cluster
helm install --namespace fleet-default --values ~/cluster-template-examples/charts/values.yaml do-cluster ./charts

## Show Registration Command
CLUSTERNAME=$(cat charts/values.yaml | sed 's/^[[:space:]]*//' | grep "^name:" | cut -d ' ' -f2)

CLUSTERID=$(kubectl get clusters.management.cattle.io -o yaml | grep -A20 "$CLUSTERNAME" | sed 's/^[[:space:]]*//' | grep "^name:" | cut -d ' ' -f2)

VAR="\"clusterId\": \"${CLUSTERID}\""

echo "Please copy the Registration Command:"
CODE=$(curl -s -k -H "Authorization: Bearer ${APITOKEN}" https://"$URL"/v3/clusterregistrationtokens | jq | grep -A7 "$VAR" | grep insecureNodeCommand | cut -d '"' -f4 | sed 's/^[[:space:]]*//')
echo "$CODE --etcd --controlplane --worker"
