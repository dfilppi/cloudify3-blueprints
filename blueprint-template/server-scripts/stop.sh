#!/bin/bash

source ${CLOUDIFY_LOGGING}

# CLOUDIFY_FILE_SERVER provides cfy_download_resource for grabbing resources in the blueprint directory via CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT
source ${CLOUDIFY_FILE_SERVER}

cfy_info "Calling test stop"

