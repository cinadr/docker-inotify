#!/bin/sh
#
# Script options (exit script on command fail).
#
set -e
API_VERSION_DEFAULT='1.24'                          #use Docker API version
API_ENDPOINT_DEFAULT='container'                    #manipulate a container
DOCKER_COMMAND_DEFAULT='restart'                    #restart container
DOCKER_PARAMS_DEFAULT=                              #no params for restart
CURL_OPTIONS_DEFAULT='-s -X POST'                   #prevent progress bar
INOTIFY_EVENTS_DEFAULT="create,delete,modify,move"  #monitor all events
INOTIFY_OPTIONS_DEFAULT='--monitor -r'              #recursive mode
SETTLE_DOWN_DEFAULT='600'                           #prevent quick multiple iterations

#
# Display settings on standard out.
#
echo "inotify settings"
echo "================"
echo
echo "  API version:      ${API_VERSION:=${API_DEFAULT}}"
echo "  API endpoint:     ${API_ENDPOINT:=${API_ENDPOINT_DEFAULT}}"
echo "  Endpoint name:    ${ENDPOINT_NAME}"
echo "  Docker command:   ${DOCKER_COMMAND:=${DOCKER_COMMAND_DEFAULT}}"
echo "  Docker params:    ${DOCKER_PARAMS:=${DOCKER_PARAMS_DEFAULT}}"
echo "  Volumes:          ${VOLUMES}"
echo "  Curl Options:     ${CURL_OPTIONS:=${CURL_OPTIONS_DEFAULT}}"
echo "  Inotify Events:   ${INOTIFY_EVENTS:=${INOTIFY_EVENTS_DEFAULT}}"
echo "  Inotify Options:  ${INOTIFY_OPTIONS:=${INOTIFY_OPTIONS_DEFAULT}}"
echo "  Settle down:      ${SETTLE_DOWN:=${SETTLE_DOWN_DEFAULT}}"
echo

#
# Prepend docker command parameters with question mark.
#
if [[ $DOCKER_PARAMS]]; then DOCKER_PARAMS="?${DOCKER_PARAMS}"

#
# Inotify part.
#
echo "[Starting inotifywait...]"
inotifywait -e ${INOTIFY_EVENTS} ${INOTIFY_OPTIONS} "${VOLUMES}" | stdbuf -oL uniq | \
    while read -r FILES;
    do
    	sleep "$SETTLE_DOWN"
        if [ `find "$FILES" -type f -newermt "$SETTLE_DOWN seconds ago" -print -quit` ]; then
		    echo "Modified: $FILES"
		    continue
	    fi
        echo "$FILES"
        echo "Notification received, performing Docker operation <${DOCKER_COMMAND}> on ${ENDPOINT_NAME} <${API_ENDPOINT}>."
        curl ${CURL_OPTIONS} --unix-socket /var/run/docker.sock http://${API_VERSION}/${API_ENDPOINT}/${ENDPOINT_NAME}/${DOCKER_COMMAND}${DOCKER_PARAMS} > /dev/stdout 2> /dev/stderr
    done
    
