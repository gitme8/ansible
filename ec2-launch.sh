#!/bin/bash

#1. create spot instance
#2. Take instance IP and register in DNS.

TEMP_ID="lt-0f74f51dfef2b396f"
TEMP_VERS=2

aws ec2 run-instances --launch-template LaunchTemplateId=${TEMP_ID},Version=${TEMP_VERS} | jq