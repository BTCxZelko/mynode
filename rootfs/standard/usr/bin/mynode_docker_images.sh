#!/bin/bash

set -e
set -x 

source /usr/share/mynode/mynode_config.sh

# Drive should be mounted, let's still wait a bit
sleep 60s

# Loop and check every 1 day
while [ 1 ]; do

    touch /tmp/installing_docker_images

    # Upgrade WebSSH2
    WEBSSH2_UPGRADE_URL=https://github.com/billchurch/webssh2/archive/v0.2.10-0.tar.gz
    WEBSSH2_UPGRADE_URL_FILE=/mnt/hdd/mynode/settings/webssh2_url
    CURRENT=""
    if [ -f $WEBSSH2_UPGRADE_URL_FILE ]; then
        CURRENT=$(cat $WEBSSH2_UPGRADE_URL_FILE)
    fi
    if [ "$CURRENT" != "$WEBSSH2_UPGRADE_URL" ]; then
        cd /opt/mynode
        rm -rf webssh2
        wget $WEBSSH2_UPGRADE_URL -O webssh2.tar.gz
        tar -xvf webssh2.tar.gz
        rm webssh2.tar.gz
        mv webssh2-* webssh2
        cd webssh2
        mv app/config.json.sample app/config.json
        docker build -t webssh2 .

        echo $WEBSSH2_UPGRADE_URL > $WEBSSH2_UPGRADE_URL_FILE
    fi

    # Upgrade mempool.space
    if [ $IS_PREMIUM -eq 1 ]; then
        MEMPOOLSPACE_UPGRADE_URL=https://github.com/mempool-space/mempool.space/archive/master.zip
        MEMPOOLSPACE_UPGRADE_URL_FILE=/mnt/hdd/mynode/settings/mempoolspace_url
        CURRENT=""
        if [ -f $MEMPOOLSPACE_UPGRADE_URL_FILE ]; then
            CURRENT=$(cat $MEMPOOLSPACE_UPGRADE_URL_FILE)
        fi
        if [ "$CURRENT" != "$MEMPOOLSPACE_UPGRADE_URL" ]; then
            cd /opt/mynode
            rm -rf mempoolspace
            wget $MEMPOOLSPACE_UPGRADE_URL -O mempool.zip
            unzip -o mempool.zip
            rm mempool.zip
            mv mempool* mempoolspace
            cd mempoolspace
            docker build -t mempoolspace .

            echo $MEMPOOLSPACE_UPGRADE_URL > $MEMPOOLSPACE_UPGRADE_URL_FILE
        fi
    fi

    rm -f /tmp/installing_docker_images

    # Check again in a day
    sleep 24h
done
