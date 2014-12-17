#!/bin/bash

# get the canned space.  Only thing special is that it has the
# site name and a reference to an enpty targets block

ctx download-resource "xap-scripts/space-pu.jar" '@{"target_path":"/tmp/space-pu.jar"}'

cluster_info=`ctx node properties cluster_info`
space_name=`ctx node properties space_name`
site_name=`ctx node properties site_name`

XAPDIR=`cat /tmp/gsdir`  # left by install script

IP_ADDR=$(ip addr | grep inet | grep eth0 | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
export LOOKUPLOCATORS=$IP_ADDR
export ZONES=$zones
if [ -f "/tmp/locators" ]; then
	LOOKUPLOCATORS=""
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
	export LOOKUPLOCATORS
fi

ctx logger info "deploying space, locators=$LOOKUPLOCATORS clusterinfo=$cluster_info"
$XAPDIR/bin/gs.sh deploy -properties "embed://spaceName=${space_name};siteName=${site_name}" -cluster $cluster_info /tmp/space-pu.jar >/tmp/deploy.out 2>&1
