#!/bin/bash

set -e

#Souce functions
source $RD_PLUGIN_BASE/functions.sh

#Get server IP Address
SERVER_IP=$(getent hosts $1 | awk '{print $1}')

#Get initial server state
get_server_state $RD_CONFIG_API_URL $SERVER_IP

#Save initial server state to tmp file
echo $SERVER_STATE > $RD_PLUGIN_BASE/$SERVER_IP

#Drain server
case $SERVER_STATE in
    up )
        SERVER_ID=$(get_curl $RD_CONFIG_API_URL/api/3/http/upstreams/$RD_CONFIG_UPSTREAM/ | $RD_PLUGIN_BASE/jq -r ".peers[] | select( .server | contains(\"$SERVER_IP\")) | .id")
        PAYLOAD="{\"drain\":true}"

        echo "Draining $1 out from upstream $RD_CONFIG_UPSTREAM"
        patch_curl $PAYLOAD $RD_CONFIG_API_URL/api/3/http/upstreams/$RD_CONFIG_UPSTREAM/servers/$SERVER_ID | $RD_PLUGIN_BASE/jq -r "."

        #Validate if drain request was successful
        sleep 3s #Waiting 3 seconds before getting server state
        NEW_SERVER_STATE=$(get_server_state $RD_CONFIG_API_URL $SERVER_IP | tail -1 | awk -F "=" '{print $2}')
        if [ "$NEW_SERVER_STATE" = "up" ] || [ -z "$NEW_SERVER_STATE" ] ; then
            echo "Drain request for server $SERVER_IP failed"
            exit 1
        fi
        ;;
    down )
        echo "Server $SERVER_IP is down from upstream $RD_CONFIG_UPSTREAM"
        echo "Proceeding without changing server state"
        exit 0
        ;;
    * )
        echo "Server state is not \"up\""
        echo "Proceeding without changing server state"
        exit 0
        ;;
esac

#Wait for 0 activity for the past 60 seconds
LAST_ACTIVE=$(get_curl $RD_CONFIG_API_URL/api/3/http/upstreams/$RD_CONFIG_UPSTREAM/ | $RD_PLUGIN_BASE/jq -r ".peers[] | select( .server | contains(\"$SERVER_IP\")) | .selected " | sed 's/T/ /')
##Fix "null" response when not "selected" value is returned from the API
if [ "$LAST_ACTIVE" = "null" ] ; then
    echo "$SERVER_IP hasn't been active for a while"

    put_server_down $SERVER_IP

    echo "$SERVER_IP have been successfully drained out from upstream $RD_CONFIG_UPSTREAM"
    exit 0
fi

NOW=$(date +%s)
IDLE_TIME=$(($NOW - `date -d "$LAST_ACTIVE" +%s`))

until [ "$IDLE_TIME" -ge "60" ] ; do
    echo "Waiting for \"0\" activity for at least 60s"
    echo "Current idle time: $IDLE_TIME"

    sleep 5s
    LAST_ACTIVE=$(get_curl $RD_CONFIG_API_URL/api/3/http/upstreams/$RD_CONFIG_UPSTREAM/ | $RD_PLUGIN_BASE/jq -r ".peers[] | select( .server | contains(\"$SERVER_IP\")) | .selected " | sed 's/T/ /')
    NOW=$(date +%s)
    IDLE_TIME=$(($NOW - `date -d "$LAST_ACTIVE" +%s`))
done

#Put server down after drain is confirmed
put_server_down $SERVER_IP

echo "$SERVER_IP have been successfully drained out from upstream $RD_CONFIG_UPSTREAM"