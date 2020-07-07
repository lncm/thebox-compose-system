
# ![Thebox](https://gitlab.com/lncm/thebox-compose-system/-/raw/master/thebox-small.png "box") The Box Compose Framework 

## Abstract

This is a basic framework for orchestration of the box services for running a full lightning and bitcoin node.

## ⚠️ A word of caution

Documentation is very sparse for now. Only use this if you know exactly what you are doing.

## 📝 How to use

Ideally, you should create a user for this and then run it within the root of that user. There are some root privilege needed stuff, however LND doesn't support tor passwords yet so we will need to wait.

### Step 1

Ensure you have the [latest docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) installed, python3 (for docker-compose), and docker-compose (installed from python3 pip).

Ensure that you have the latest tor (currently working with 0.3.5.8), and you are using system default paths.

For the install script, you should also have git installed.

For the configuration script you should also have wget.

These scripts all are able to run as non-interactive sessions.

### Step 2

Ensure that your account is permissioned for docker.

### Step 3

Run this from your home directory. This clones this repo into your home directory, as well as preserving the existing structure.

```bash
# This can run in anywhere. Ideally HOME, but you can use multiple folders with different installs if you wish to keep things separate
# This will not overwrite any other files but you should segment this in its
# own folder
curl "https://raw.githubusercontent.com/lncm/thebox-compose-system/master/install-box.sh" | sh
# OR wget (if this works better)
wget -qO- "https://raw.githubusercontent.com/lncm/thebox-compose-system/master/install-box.sh" | sh

# Alternatively
curl "https://gitlab.com/lncm/thebox-compose-system/-/raw/master/install-box.sh" | sh
# or (wget)
wget -qO- "https://gitlab.com/lncm/thebox-compose-system/-/raw/master/install-box.sh" | sh
```

## 📝 Configuring

```bash
# If you want to use testnet or regtest (just use REGTEST=true), otherwise we will use mainnet by default and be #reckless
# Some instructions on working with regtest is below
export TESTNET=true
# testnet mode not supported as config is completely different

# Run this in the $HOME directory
wget -qO- "https://raw.githubusercontent.com/lncm/thebox-compose-system/master/configure-box.sh" | sh
# or (should be in the $HOME directory after install)
./configure-box.sh
```

## 📝 Running

```bash
# Build containers in build/ always
docker-compose up -d --build
# verify the containers
docker ps -a

# Additional node: You should have a way of creating a wallet. Currently this container does not have a create wallet container.
# For the unlock script to work, put the unlock password in secrets/lnd-password.txt
```


## 📝 Configuring and Running in Regtest mode

After fetching this (or after a branch reset)

### Configure the box

```bash
export REGTEST=true
./configure-box.sh
```

### Start docker-compose and build

```bash
docker-compose up --build
# or (in detached mode)
docker-compose up --build -d
```

### Generate a wallet and address

```bash
# Must create a wallet
docker exec -it lncm_lnd_1 lncli --network=regtest create
docker exec -it lncm_lnd_1 lncli --network=regtest newaddress p2wkh
```

### Mine some bitcoins into the address to use for channels

```bash
docker exec -it lncm_bitcoin_1 bitcoin-cli generatetoaddress 1 <address-generated>
```

Now you should be ready to open channels, and theoretically you can link multiple LND nodes (as long as they connect to the same bitcoind for reference)


## ✅ TODO List

Please see the [following tasks](https://github.com/lncm/thebox-compose-system/issues?q=is%3Aissue+is%3Aopen+label%3ATODO) which are on this list.
