#!/bin/bash

set -e

#Souce functions
source $RD_PLUGIN_BASE/functions.sh

#Get server IP Address
SERVER_IP=$(getent hosts $1 | awk '{print $1}')

#Get initial server state
INITIAL_SERVER_STATE=$(cat $RD_PLUGIN_BASE/$SERVER_IP)

#Set server back up
if [ "$INITIAL_SERVER_STATE" = "up" ] ; then
    put_server_up $SERVER_IP
else
    echo "Initial server state was: $INITIAL_SERVER_STATE"
    echo "Proceeding without changing server state"
fi

#Remove tmp state file
rm -f $RD_PLUGIN_BASE/$SERVER_IP