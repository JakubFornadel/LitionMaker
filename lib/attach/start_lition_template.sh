#!/bin/bash
set -u
set -e

cd /root/lition-maker/
./start_nodemanager.sh -r $R_PORT -g $NM_PORT -i $CURRENT_NODE_IP -c $CHAIN_ID -m $MINING_FLAG
