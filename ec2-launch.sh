#!/bin/bash

#1. create spot instance
#2. Take instance IP and register in DNS.

if [ -z "$1" ]; then
  echo -e "\e[1:31mInput is missing\e[0m"
  exit 1
fi
COMPONENT=$1
TEMP_ID="lt-0dd90876b45053146"
TEMP_VERS=1

aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" | jq .Reservations[].Instances[].State.Name | sed 's/"//g' | grep -E 'running|stopped' &>/dev/null
if [ $? -eq -0 ]; then
  echo -e "\e[1;33mInstance is already there\e[0m"
  exit
fi

aws ec2 run-instances --launch-template LaunchTemplateId=${TEMP_ID},Version=${TEMP_VERS} --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=${COMPONENT}}]"  "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" | jq