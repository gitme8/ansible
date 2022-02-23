#!/bin/bash

#1. create spot instance
#2. Take instance IP and register in DNS.

TEMP_ID="lt-0dd90876b45053146"
TEMP_VERS=1

aws ec2 run-instances --launch-template LaunchTemplateId=${TEMP_ID},Version=${TEMP_VERS} --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=Frontend}]"  "ResourceType=instance,Tags=[{Key=Name,Value=Frontend}]"  | jq