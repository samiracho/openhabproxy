#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
IP_CURRENT=$([ -e "$DIR/../data/ip" ] && cat "$DIR/../data/ip" || echo "")
IP_PREVIOUS=$([ -e "$DIR/../data/ip_prev" ] && cat "$DIR/../data/ip_prev" || echo "")

#HOME_DNS=$(doctl compute domain records list racho.es --no-header --format ID,Name,Data | grep home)
#HOME_DNS_ID=$(echo ${HOME_DNS} | awk '{print $1}')
#HOME_DNS_DATA=$(echo ${HOME_DNS} | awk '{print $3}')

source "${DIR}/.config"
export $(cut -d= -f1 "${DIR}/.config")

if [ -z "$IP_CURRENT" ]; then

   echo "ERROR: empty IP" && exit 1

elif [ "$IP_CURRENT" != "$IP_PREVIOUS" ]; then

    echo "IP changed. Updating nginx config."
    export PROXY_SERVER="$IP_CURRENT"
    envsubst '${PROXY_SERVER} ${PROXY_PORT} ${SERVER_NAME} ${SITE_PATH}' < "${DIR}/siteconfig.template" > "${SITES_AVAILABLE_DIR}/${SERVER_NAME}"
    echo "$IP_CURRENT" > "$DIR/../data/ip_prev"

    if [ ! -e "${SITES_ENABLED_DIR}/${SERVER_NAME}" ]; then
        ln -s "${SITES_AVAILABLE_DIR}/${SERVER_NAME}" "${SITES_ENABLED_DIR}/${SERVER_NAME}"
    fi

    service nginx reload
    echo "Update done."

else
    echo "IP ${IP_CURRENT} not changed since last check. Doing nothing."
fi
