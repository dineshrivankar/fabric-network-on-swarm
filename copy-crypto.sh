#!/bin/bash

# ---------------------------------------------------------------------------
# Clear screen
# ---------------------------------------------------------------------------
clear

echo "# ---------------------------------------------------------------------------"
echo "# Remove old crypto material"
echo "# ---------------------------------------------------------------------------"
rm -rf mkdir /var/mynetwork/*

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Create directories to copy crypto material"
echo "# ---------------------------------------------------------------------------"
mkdir -p /var/mynetwork/chaincode /var/mynetwork/certs /var/mynetwork/bin /var/mynetwork/fabric-src

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Clone fabric repository"
echo "# ---------------------------------------------------------------------------"
git clone https://github.com/hyperledger/fabric /var/mynetwork/fabric-src/hyperledger/fabric
cd /var/mynetwork/fabric-src/hyperledger/fabric
git checkout release-1.4

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Copy new crypto material"
echo "# ---------------------------------------------------------------------------"
cd -
cp -R crypto-config /var/mynetwork/certs/
cp -R config /var/mynetwork/certs/
cp -R chaincodes/* /var/mynetwork/chaincode/
cp -R bin/* /var/mynetwork/bin/
