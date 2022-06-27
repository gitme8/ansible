#!/bin/bash

#1. create SPOT instance
#2. Take instance IP and register in DNS.

if [ -z "$1" ]; then
  echo -e "\e[1:31mInput is missing\e[0m"
  exit 1
fi

COMPONENT=$1
ENV=$2

if [ ! -z "$ENV" ]; then
  ENV="-${ENV}"
fi

TEMP_ID="lt-0496bcb640126f886"
TEMP_VERS=2
ZONE_ID=Z07159021W8INOC5QR8AE

CREATE_INSTANCE() {
  ## Check if instance exist already
  aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" | jq .Reservations[].Instances[].State.Name | sed 's/"//g' | grep -E 'running|stopped' &>/dev/null
  if [ $? -eq -0 ]; then
    echo -e "\e[1;33mInstance is already there\e[0m"
  else
    aws ec2 run-instances --launch-template LaunchTemplateId=${TEMP_ID},Version=${TEMP_VERS} --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=${COMPONENT}}]" "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" | jq
  fi
  sleep 10

  IPADDRESS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" | jq .Reservations[].Instances[].PrivateIpAddress | sed 's/"//g' | grep -v null)

  ## update DNS record
  sed -e "s/IPADDRESS/${IPADDRESS}/" -e "s/COMPONENT/${COMPONENT}/" record.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json | jq
}

if [ "$COMPONENT" == "all" ]; then
#  for comp in frontend mongodb catalogue redis user cart mysql shipping rabbitmq payment dispatch; do
   for comp in frontend mongodb catalogue redis user cart mysql; do
    COMPONENT=$comp$ENV
    CREATE_INSTANCE
  done
else
  COMPONENT=$COMPONENT$ENV
  CREATE_INSTANCE
fi
