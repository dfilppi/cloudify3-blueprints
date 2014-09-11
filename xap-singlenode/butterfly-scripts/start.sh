#!/bin/sh
source ${CLOUDIFY_LOGGING}

function error_exit {
   cfy_error "$2 : error code: $1"
   exit ${1}
}

GSDIR=`cat /tmp/gsdir`
LOOKUPLOCATORS=""
for line in $(cat /tmp/locators); do
	LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
done
LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
export LOOKUPLOCATORS
export GS_GROOVY_HOME=$GSDIR/tools/groovy/
export EXT_JAVA_OPTIONS="-Dcom.gs.multicast.enabled=false"
export GS_HOME=$GSDIR

UUID=asdfsd

source ~/.bashrc
source /tmp/virtenv_is/bin/activate

UUID=`uuidgen`

cfy_info "launching butterfly server"
python /tmp/demodl/butterfly/butterfly.server.py --host="0.0.0.0" --port="$port" --unsecure --prompt_login=false --load_script="/tmp/demodl/XAP-Interactive-Tutorial-1.0/start_tutorial.sh" --wd="/tmp/demodl" $UUID &
sleep 1
cfy_info "launched butterfly server"
deactivate
cfy_info "deactivated"

