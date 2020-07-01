#!/bin/bash

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# Install the docker-compose box to the current working directory
# Pre-requisites: wget

echo "Start box configuration"
echo "Installing RPCAuth.py and configuring secrets"
cd bin/
wget -q "https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/rpcauth/rpcauth.py" 2>/dev/null
chmod 755 rpcauth.py
./rpcauth.py lncm | tee ../secrets/generated.txt | head -2 | tail -1 > ../secrets/rpcauth.txt
tail -1 ../secrets/generated.txt > ../secrets/rpcpass.txt
rm rpcauth.py ../secrets/generated.txt
cd ..
echo "Installing RPCAuth into bitcoin.conf"
cat secrets/rpcauth.txt >> bitcoin/bitcoin.conf
RPCPASS=`cat secrets/rpcpass.txt`
echo "Configuring invoicer rpc info"
sed -i "s/RPCPASS/${RPCPASS}/g; " invoicer/invoicer.conf
echo "Configuring LND rpc info"
sed -i "s/RPCPASS/${RPCPASS}/g; " lnd/lnd.conf
if [ ! -z $TESTNET ] && [ -z $REGTEST ]; then
    echo "Enabling testnet mode if TESTNET variable is set"
    sed -i 's/\#\[test\]/\[test\]/g;' bitcoin/bitcoin.conf 
    sed -i 's/\#testnet=1/testnet=1/g' bitcoin/bitcoin.conf
    sed -i 's/rpcport=8332/rpcport=18332/g; ' bitcoin/bitcoin.conf
    sed -i 's/port=8332/port=18333/g; ' bitcoin/bitcoin.conf
    echo "Configure invoicer (change RPC port to 18332)"
    sed 's/port = 8332/port = 18332/g; ' invoicer.conf
    echo "Changing LND to testnet mode"
    sed -i 's/bitcoin.mainnet=1/bitcoin.testnet=1/g; ' lnd/lnd.conf
    echo "Updating LND neutrino peers"
    sed -i 's/neutrino.addpeer=bb2.breez.technology/\;neutrino.addpeer=bb2.breez.technology/g; ' lnd/lnd.conf
    sed -i 's/neutrino.addpeer=mainnet1-btcd.zaphq.io/\;neutrino.addpeer=mainnet1-btcd.zaphq.io/g; ' lnd/lnd.conf
    sed -i 's/neutrino.addpeer=mainnet2-btcd.zaphq.io/\;neutrino.addpeer=mainnet2-btcd.zaphq.io/g;' lnd/lnd.conf
    sed -i 's/\;neutrino.addpeer=testnet1-btcd.zaphq.io/neutrino.addpeer=testnet1-btcd.zaphq.io/g;' lnd/lnd.conf
    sed -i 's/\;neutrino.addpeer=testnet2-btcd.zaphq.io/neutrino.addpeer=testnet2-btcd.zaphq.io/g; ' lnd/lnd.conf
fi
# REGTEST set and TESTNET not
if [ -z $TESTNET ] && [ ! -z $REGTEST ]; then
    echo "Enabling regtest mode if REGTEST variable is set"
    sed -i 's/\#\[regtest\]/\[regtest\]/g;' bitcoin/bitcoin.conf
    sed -i 's/\#regtest=1/regtest=1/g' bitcoin/bitcoin.conf
    sed -i 's/rpcport=8332/rpcport=18443/g; ' bitcoin/bitcoin.conf
    sed -i 's/port=8333/port=18444/; ' bitcoin/bitcoin.conf
    echo "Configure invoicer (Change RPC port to 18443)"
    sed -i 's/port = 8332/port = 18443/g; ' invoicer.conf
    # update LND
    echo "Changing LND to regtest mode"
    sed -i 's/bitcoin.mainnet=1/bitcoin.regtest=1/g; ' lnd/lnd.conf
    echo "Updating LND if regtest is set. Lets use bitcoind node"
    sed -i 's/bitcoin.node=neutrino/bitcoin.node=bitcoind/g; ' lnd/lnd.conf
fi

# Generate a TOR password
echo "Adding tor password"
# TODO: Use docker built tor so we eliminate dependencies
SAVE_PASSWORD=`tor --hash-password "${RPCPASS}"`
echo "HashedControlPassword ${SAVE_PASSWORD}" >> tor/torrc
echo "Configuring bitcoind"
sed -i "s/torpassword=lncmrocks/torpassword=${RPCPASS}/g;" bitcoin/bitcoin.conf
echo "Configuring LND"
sed -i "s/tor.password=lncmrocks/tor.password=${RPCPASS}/g; " lnd/lnd.conf

rm configure-box.sh
echo "Box Configuration complete"

