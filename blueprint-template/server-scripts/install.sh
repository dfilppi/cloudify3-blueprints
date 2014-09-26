#!/bin/bash

source ${CLOUDIFY_LOGGING}

# CLOUDIFY_FILE_SERVER provides cfy_download_resource for grabbing resources in the blueprint directory via CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT
source ${CLOUDIFY_FILE_SERVER}

cfy_info "Calling test install"

# pull down a utility script that defines a function for setting
# runtime attributes
wget -O /tmp/util.sh "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/server-scripts/util.sh"
wget -O /tmp/jq "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/server-scripts/jq"
chmod +x /tmp/jq
source /tmp/util.sh

# get the ip
IP_ADDR=$(ip addr | grep inet | grep eth0 | awk -F" " '{print $2}'| sed -e 's/\/.*$//')

# set it in runtime properties
set_runtime_properties "ip_address" $IP_ADDR

cfy_info "Set IP to ${IP_ADDR}"
