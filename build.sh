#!/bin/bash
#set -x

RED='\033[1;31m' # alarm
GRN='\033[1;32m' # notice
YEL='\033[1;33m' # warning
NC='\033[0m' # No Color

source env.txt

which kubectl &>/dev/null
if [[ "$?" != 0 ]]; then
  printf "${RED}==Please install kubectl==${NC}\n" && exit 0
  which jq &>/dev/null
elif [[ "$?" != 0 ]]; then
  printf "${RED}==Please install jq==${NC}\n" && exit 0
  which helm &>/dev/null
elif [[ "$?" != 0 ]]; then
  printf "${RED}==Please install helm==${NC}\n" && exit 0
fi

LOGINRESPONSE=`curl -s "https://${URL}/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"'${USER}'","password":"'${PASSWORD}'"}' --insecure`

LOGINTOKEN=`echo $LOGINRESPONSE | jq -r .token`

APIRESPONSE=`curl -s "https://${URL}/v3/token" -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure`

APITOKEN=`echo $APIRESPONSE | jq -r .token`

printf "${GRN}==Please copy the following token:==${NC}\n"
echo -e "${APITOKEN}\n"

## Create Custom Cluster
helm install --namespace fleet-default --values charts/values.yaml do-cluster ./charts &>/dev/null

## Show Registration Command
CLUSTERNAME=$(cat charts/values.yaml | sed 's/^[[:space:]]*//' | grep "^name:" | cut -d ' ' -f2 | tr -d '\r')

CLUSTERID=$(kubectl get clusters.management.cattle.io -o yaml | grep -A20 "$CLUSTERNAME" | sed 's/^[[:space:]]*//' | grep "^name:" | cut -d ' ' -f2)

VAR="\"clusterId\": \"${CLUSTERID}\""

printf "${GRN}==Please copy the Registration Allinone Command:==${NC}\n"
CODE=$(curl -s -k -H "Authorization: Bearer ${APITOKEN}" https://"$URL"/v3/clusterregistrationtokens | jq | grep -A7 "$VAR" | grep insecureNodeCommand | cut -d '"' -f4 | sed 's/^[[:space:]]*//')
echo "$CODE --etcd --controlplane --worker"
