#!/bin/bash -e

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# Directories
# Allow access to /secrets/rpcpass.txt
# Allow access to LND directory (use /lnd/lnd.conf)
# Allow access to 'statuses'. /statuses/

PASSWORD=`cat /secrets/rpcpass.txt`
JSONRPCURL="http://10.254.2.2:18332"

INFO=`curl --user lncm:$PASSWORD --data-binary '{"jsonrpc": "1.0", "id":"switchme", "method": "getblockchaininfo", "params": [] }' $JSONRPCURL 2>/dev/null`

HEADERS=`echo $INFO | jq .result.headers`
BLOCKS=`echo $INFO | jq .result.blocks`

while true; do
  echo "Checking if synced...."
  if [ $HEADERS -eq $BLOCKS ]; then
      echo "Switching over from bitcoind to neutrino"
      #sed 's/bitcoin.node\=neutrino/bitcoin.node\=bitcoind/g; ' /lnd/lnd.conf
  fi
  # Run every every 1 minute for testing
  sleep 60
done
