#!/bin/bash

source .env

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
  echo "  	./deploy.sh <mode> [-o <consensus-type>]"
  echo "  	-o <consensus-type> - the consensus-type of the ordering service: solo (default), kafka, or etcdraft"
  echo "	e.g.: ./deploy.sh -o solo"
  echo
}

if [ "$OPTION" == "-o" ]; then
	if [ "$CONSENSUS_TYPE" == "solo" ] || [ "$CONSENSUS_TYPE" == "kafka" ] || [ "$CONSENSUS_TYPE" == "etcdraft" ]; then
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
echo "# Update Hostname"
echo "# ---------------------------------------------------------------------------"
echo "Making Hostname changes..."

if [ "$CONSENSUS_TYPE" == "solo" ]; then
	sed -i "s/- node.hostname == .*/- node.hostname == $ORDERER_HOSTNAME/g" solo/docker-compose-orderer.yml
elif [ "$CONSENSUS_TYPE" == "kafka" ]; then
	sed -i "s/- node.hostname == .*/- node.hostname == $ORDERER_HOSTNAME/g" kafka/docker-compose-orderer.yml
	sed -i "s/- node.hostname == .*/- node.hostname == $ORDERER_HOSTNAME/g" kafka/docker-compose-orderer-kafka.yml
	sed -i "s/- node.hostname == .*/- node.hostname == $ORDERER_HOSTNAME/g" kafka/docker-compose-orderer-zookeeper.yml
elif [ "$CONSENSUS_TYPE" == "etcdraft" ]; then
	sed -i "s/- node.hostname == .*/- node.hostname == $ORDERER_HOSTNAME/g" etcdraft/docker-compose-orderer.yml
fi
sed -i "s/- node.hostname == .*/- node.hostname == $ORG1_HOSTNAME/g" org/docker-compose-org1.yml
sed -i "s/- node.hostname == .*/- node.hostname == $ORG2_HOSTNAME/g" org/docker-compose-org2.yml
sleep 3 

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Deploy Orderer node"
echo "# ---------------------------------------------------------------------------"
if [ "$CONSENSUS_TYPE" == "solo" ]; then
	docker stack deploy --compose-file solo/docker-compose-orderer.yml orderer
elif [ "$CONSENSUS_TYPE" == "kafka" ]; then
	docker stack deploy --compose-file kafka/docker-compose-orderer-zookeeper.yml zookeeper
	docker stack deploy --compose-file kafka/docker-compose-orderer-kafka.yml kafka
	docker stack deploy --compose-file kafka/docker-compose-orderer.yml orderer
elif [ "$CONSENSUS_TYPE" == "etcdraft" ]; then
	docker stack deploy --compose-file etcdraft/docker-compose-orderer.yml orderer
fi
sleep 5 

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Deploy Org1 nodes"
echo "# ---------------------------------------------------------------------------"
docker stack deploy --compose-file org/docker-compose-org1.yml org1
sleep 3 

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Deploy Org2 nodes"
echo "# ---------------------------------------------------------------------------"
docker stack deploy --compose-file org/docker-compose-org2.yml org2


