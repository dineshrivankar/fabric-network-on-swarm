#!/bin/bash

source .env

# ---------------------------------------------------------------------------
# Clear screen
# ---------------------------------------------------------------------------
clear

echo "# ---------------------------------------------------------------------------"
echo "# Create Channel : mychannel"
echo "# ---------------------------------------------------------------------------"
docker exec "$CLI_NAME" peer channel create -o "$ORDERER_NAME":7050 -c "$CHANNEL_NAME" -f "$CHANNEL_TX_LOCATION" --tls --cafile $ORDERER_CA_LOCATION
sleep 2

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Join channel : peer0.org1.example.com "
echo "# ---------------------------------------------------------------------------"
docker exec "$CLI_NAME" peer channel join -b "$CHANNEL_NAME".block --tls --cafile $ORDERER_CA_LOCATION
sleep 2

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Join channel : peer1.org1.example.com"
echo "# ---------------------------------------------------------------------------"
docker exec \
	-e "CORE_PEER_LOCALMSPID=Org1MSP" \
	-e "CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/server.crt" \
	-e "CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/server.key" \
	-e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt" \
	-e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" \
	-e "CORE_PEER_ADDRESS=peer1.org1.example.com:7051" \
	"$CLI_NAME" peer channel join -b "$CHANNEL_NAME".block --tls --cafile $ORDERER_CA_LOCATION
sleep 2

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Join channel : peer0.org2.example.com"
echo "# ---------------------------------------------------------------------------"
docker exec \
	-e "CORE_PEER_LOCALMSPID=Org2MSP" \
	-e "CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt" \
	-e "CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key" \
	-e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
	-e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" \
	-e "CORE_PEER_ADDRESS=peer0.org2.example.com:7051" \
	"$CLI_NAME" peer channel join -b "$CHANNEL_NAME".block --tls --cafile $ORDERER_CA_LOCATION
sleep 2

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Join channel : peer1.org2.example.com"
echo "# ---------------------------------------------------------------------------"
docker exec \
	-e "CORE_PEER_LOCALMSPID=Org2MSP" \
	-e "CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/server.crt" \
	-e "CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/server.key" \
	-e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt" \
	-e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" \
	-e "CORE_PEER_ADDRESS=peer1.org2.example.com:7051" \
	"$CLI_NAME" peer channel join -b "$CHANNEL_NAME".block --tls --cafile $ORDERER_CA_LOCATION
sleep 2

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Update anchor peer : Org1"
echo "# ---------------------------------------------------------------------------"
docker exec "$CLI_NAME" peer channel update  -o "$ORDERER_NAME":7050 -c "$CHANNEL_NAME" -f "$ORG1_ANCHOR_TX" --tls --cafile $ORDERER_CA_LOCATION
sleep 2

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Update anchor peer : Org2"
echo "# ---------------------------------------------------------------------------"
docker exec \
	-e "CORE_PEER_LOCALMSPID=Org2MSP" \
	-e "CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt" \
	-e "CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key" \
	-e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
	-e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" \
	-e "CORE_PEER_ADDRESS=peer0.org2.example.com:7051" \
	"$CLI_NAME" peer channel update  -o "$ORDERER_NAME":7050 -c "$CHANNEL_NAME" -f "$ORG2_ANCHOR_TX" --tls --cafile $ORDERER_CA_LOCATION
sleep 2

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Installing chaincode on org1"
echo "# ---------------------------------------------------------------------------"
docker exec "$CLI_NAME" peer chaincode install -n "$CHAINCODE_NAME" -p "$CHAINCODE_SRC" -v $CHAINCODE_VERSION
sleep 2

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Installing chaincode on org2"
echo "# ---------------------------------------------------------------------------"
docker exec \
	-e "CORE_PEER_LOCALMSPID=Org2MSP" \
	-e "CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt" \
	-e "CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key" \
	-e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
	-e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" \
	-e "CORE_PEER_ADDRESS=peer0.org2.example.com:7051" \
	"$CLI_NAME" peer chaincode install -n "$CHAINCODE_NAME" -p "$CHAINCODE_SRC" -v $CHAINCODE_VERSION
sleep 2

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Instantiating chaincode: A=100,B=200"
echo "# ---------------------------------------------------------------------------"
docker exec "$CLI_NAME" peer chaincode instantiate -o "$ORDERER_NAME":7050 -C "$CHANNEL_NAME" -n "$CHAINCODE_NAME" "$CHAINCODE_SRC" -v $CHAINCODE_VERSION  -c '{"Args":["init","a", "100", "b","200"]}' -P "OR('Org1MSP.member', 'Org2MSP.member')" --tls --cafile $ORDERER_CA_LOCATION
sleep 10 

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Listing to installed chaincodes"
echo "# ---------------------------------------------------------------------------"
docker exec "$CLI_NAME" peer chaincode list --instantiated -C "$CHANNEL_NAME" --tls --cafile $ORDERER_CA_LOCATION
sleep 10

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Invoking chaincode : Move 10 from A to B"
echo "# ---------------------------------------------------------------------------"
docker exec "$CLI_NAME" peer chaincode invoke -o "$ORDERER_NAME":7050 --tls --cafile $ORDERER_CA_LOCATION -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["move","a","b","10"]}'
sleep 5

echo 
echo "# ---------------------------------------------------------------------------"
echo "# Query chaincode: Query A"
echo "# ---------------------------------------------------------------------------"
docker exec "$CLI_NAME" peer chaincode query -o "$ORDERER_NAME":7050 --tls --cafile $ORDERER_CA_LOCATION -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["query","a"]}'