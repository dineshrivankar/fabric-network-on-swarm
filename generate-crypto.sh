#!/bin/bash

source .env
export PATH=$PATH:${PWD}/bin
export FABRIC_CFG_PATH=${PWD}

# ---------------------------------------------------------------------------
# Clear screen
# ---------------------------------------------------------------------------
clear

OPTION=$1
CONSENSUS_TYPE=$2

# ---------------------------------------------------------------------------
# Help screen
# ---------------------------------------------------------------------------
function printHelp() {
  echo 
  echo "Usage: "
  echo "  	./generate-crypto.sh <mode> [-o <consensus-type>]"
  echo "  	-o <consensus-type> - the consensus-type of the ordering service: solo (default), kafka, or etcdraft"
  echo "	e.g.: ./generate-crypto.sh -o solo"
  echo
}

if [ "$OPTION" == "-o" ]; then
	if [ "$CONSENSUS_TYPE" == "solo" ] || [ "$CONSENSUS_TYPE" == "kafka" ] || [ "$CONSENSUS_TYPE" == "etcdraft" ]; then
		rm -f configtx.yaml crypto-config.yaml
		cp -a ${CONSENSUS_TYPE}/configtx.yaml ${PWD}
		cp -a ${CONSENSUS_TYPE}/crypto-config.yaml ${PWD}
	elif [ "$CONSENSUS_TYPE" == "" ]; then
		printHelp
		exit 1
	else
		echo "unrecognized consesus type '$CONSENSUS_TYPE'. exiting..."
		printHelp
		exit 1
	fi
else
	printHelp
	exit 1
fi

echo "# ---------------------------------------------------------------------------"
echo "# Remove old artifacts"
echo "# ---------------------------------------------------------------------------"
rm -fr crypto-config/* config/*

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Generate crypto material"
echo "# ---------------------------------------------------------------------------"
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Generate genesis block for orderer"
echo "# ---------------------------------------------------------------------------"
configtxgen -profile OrdererGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Generate channel configuration transaction for My Channel"
echo "# ---------------------------------------------------------------------------"
configtxgen -profile ${CHANNEL_PROFILE} -outputCreateChannelTx ./config/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME

if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Generate anchor peer for ORG1 Org"
echo "# ---------------------------------------------------------------------------"
configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./config/Org1MSPanchors_${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Generate anchor peer for ORG2 Org"
echo "# ---------------------------------------------------------------------------"
configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./config/Org2MSPanchors_${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org2MSP..."
  exit 1
fi

