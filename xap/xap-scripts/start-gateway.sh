#!/bin/bash

ctx download-resource "xap-scripts/nat-mapper.jar" '@{"target_path":"/tmp/space-pu.jar"}'
ctx download-resource "xap-scripts/startgsc.groovy"  '@{target_path":"/tmp/startgsc.groovy"}' 
ctx download-resource "xap-scripts/install_gateway.groovy" '@{target_path":"/tmp/install_gateway.groovy"}'
ctx download-resource "xap-scripts/gateway-pu.xml"  '@{target_path":"/tmp/gateway-pu.xml"}'
ctx download-resource "xap-scripts/util.sh" '@{target_path":"/tmp/util.sh"}'
ctx download-resource "xap-scripts/jq" '@{target_path":"/tmp/jq"}'

zones=`ctx node properties zones`
targets=`ctx node properties targets`
sources=`ctx node properties sources`
local_site=`ctx node properties local_site`
lookups=`ctx node properties lookups`
discover_port=`ctx node properties discover_port`
comm_port=`ctx node properties comm_port`
nat_mappings=`ctx node properties nat_mappings`

chmod +x /tmp/jq
source /tmp/util.sh

sudo ulimit -n 32000
sudo ulimit -u 32000

XAPDIR=`cat /tmp/gsdir`  # left by install script

# Update IP
IP_ADDR=$(ip addr | grep inet | grep eth0 | awk -F" " '{print $2}'| sed -e 's/\/.*$//')

ctx logger info "About to post IP address ${IP_ADDR}"

set_runtime_properties "ip_address" $IP_ADDR

export LOOKUPGROUPS=
export GSA_JAVA_OPTIONS
export LUS_JAVA_OPTIONS
export GSM_JAVA_OPTIONS
export GSC_JAVA_OPTIONS

LOOKUPLOCATORS=$IP_ADDR
if [ -f "/tmp/locators" ]; then
	LOOKUPLOCATORS=""
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
fi

# Write empty NAT mapping file (required by mapper)
echo > /tmp/network_mapping.config

PS=`ps -eaf|grep -v grep|grep GSA`

export EXT_JAVA_OPTIONS="-Dcom.gs.multicast.enabled=false -Dcom.gs.transport_protocol.lrmi.bind-port=${comm_port} -Dcom.sun.jini.reggie.initialUnicastDiscoveryPort=${discovery_port} -Dcom.gs.transport_protocol.lrmi.network-mapping-file=/tmp/network_mapping.config -Dcom.gs.transport_protocol.lrmi.network-mapper=org.openspaces.repl.natmapper.ReplNatMapper"

if [ -n "${zones}" ]; then
	ZONES=$zones
else
	ZONES="${local_site}-gw"
fi

if [ "$PS" = "" ]; then  #no gsa running already
	export LOOKUPLOCATORS
	export NIC_ADDR=$LOOKUPLOCATORS

	GSC_JAVA_OPTIONS="$GSC_JAVA_OPTIONS -Dcom.gs.zones=${ZONES}"

	ctx logger info "running gs-agent.sh from $CLOUDIFY_NODE_ID"

	nohup $XAPDIR/bin/gs-agent.sh gsa.global.lus=0 gsa.lus=0 gsa.global.gsm=0 gsa.gsm 0 gsa.gsc=1 2>&1 >/tmp/xap.nohup.out &

	sleep 10

else 

	GROOVY=$XAPDIR/tools/groovy/bin/groovy

	ctx logger info "GSA already running"

	EXT_JAVA_OPTIONS="${EXT_JAVA_OPTIONS} -Dcom.gs.zones=${ZONES}"

	ctx logger info "calling:  $GROOVY /tmp/startgsc.groovy \"$JAVA_OPTIONS $EXT_JAVA_OPTIONS\""

	$GROOVY /tmp/startgsc.groovy "$JAVA_OPTIONS $EXT_JAVA_OPTIONS"

	ctx logger info "called startgsc"

fi

# Create and deploy pu
# first add this gateway to lookups

lookups=${lookups%"]"}
lookups="${lookups},[gwname:$local_site,address:$IP_ADDR,discoport:$discovery_port,commport:$comm_port]]"

$GROOVY /tmp/install_gateway.groovy "${local_site}-gw" "${space_name}" "$ZONES" "$LOOKUPLOCATORS" "${local_site}" "${targets}" "${sources}" "${lookups}" "${nat_mappings}"

