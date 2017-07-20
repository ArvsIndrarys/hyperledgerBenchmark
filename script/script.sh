#!/bin/bash


echo "===================================================================="
echo "======================= Creating channel ==========================="
echo "===================================================================="

peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

sleep 3

echo "===================================================================="
echo "=================== Joining peer0 to channel ======================="
echo "===================================================================="


peer channel join -b mychannel.block

sleep 3

echo "===================================================================="
echo "====================== Installing chaincode ========================"
echo "===================================================================="

peer chaincode install -n chaincode -v 1.0 -p github.com/hyperledger/fabric/peer/chaincode
sleep 3

echo "===================================================================="
echo "=================== Instantiating  chaincode ======================="
echo "===================================================================="

peer chaincode instantiate -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt -C $CHANNEL_NAME -n chaincode -v 1.0  -c '{"Args":["init"]}' -P "OR ('Org1MSP.member','Org2MSP.member')"

echo "===================================================================="
echo "==================== Finished instantiating  ======================="
echo "===================================================================="

