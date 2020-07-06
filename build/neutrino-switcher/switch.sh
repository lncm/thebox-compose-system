#!/bin/bash -e

# Directories
# Allow access to /secrets/rpcpass.txt
# Allow access to LND directory (use /lnd/lnd.conf)
# Allow access to 'statuses'. /statuses/

PASSWORD=`cat /secrets/rpcpass.txt`
JSONRPCURL="http://10.254.2.2:18332"

INFO=`curl --user lncm:$PASSWORD --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getblockchaininfo", "params": [] }' $JSONRPCURL 2>/dev/null`

HEADERS=`echo $INFO | jq .result.headers`
BLOCKS=`echo $INFO | jq .result.blocks`

if [ $HEADERS -eq $BLOCKS ]; then
    echo "Switching over from bitcoind to neutrino"
    sed 's/bitcoin.node\=neutrino/bitcoin.node\=bitcoind/g; ' /lnd/lnd.conf
fi
