#!/bin/bash


echo "===================================================================="
echo "======================= Creating channel ==========================="
echo "===================================================================="

peer channel create -o testing_orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/testing_orderer.example.com/tls/ca.crt

sleep 3

echo "===================================================================="
echo "=================== Joining peer0 to channel ======================="
echo "===================================================================="


peer channel join -b sunchain.block

sleep 3

echo "===================================================================="
echo "================= Installing sunchain chaincode ===================="
echo "===================================================================="

peer chaincode install -n sunchaincode -v 1.0 -p github.com/hyperledger/fabric/peer/sunchaincode
sleep 3

echo "===================================================================="
echo "=================== Instantiating  chaincode ======================="
echo "===================================================================="

peer chaincode instantiate -o testing_orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/testing_orderer.example.com/tls/ca.crt -C $CHANNEL_NAME -n sunchaincode -v 1.0  -c '{"Args":["init"]}' -P "OR ('Org1MSP.member','Org2MSP.member')"

echo "===================================================================="
echo "==================== Finished instantiating  ======================="
echo "===================================================================="

