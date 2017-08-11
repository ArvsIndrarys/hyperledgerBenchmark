#!/bin/bash

function channelJoin {
	
	echo "----------------- peer0org1 -----------------"
	CORE_PEER_ADDRESS=peer0.org1.example.com:7051
	CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
	CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
	CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

	peer channel join -b mychannel.block
	peer chaincode install -n chaincode -v 1.0 -p github.com/hyperledger/fabric/peer/chaincode

	echo "----------------- peer1org1 -----------------"
	CORE_PEER_ADDRESS=peer1.org1.example.com:7051
	CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/server.crt
	CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/server.key
	CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
	
	peer channel join -b mychannel.block
	peer chaincode install -n chaincode -v 1.0 -p github.com/hyperledger/fabric/peer/chaincode

#	echo "----------------- peer2org1 -----------------"
#	CORE_PEER_ADDRESS=peer2.org1.example.com:7051
#	CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer2.org1.example.com/tls/server.crt
#	CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer2.org1.example.com/tls/server.key
#	CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer2.org1.example.com/tls/ca.crt
#	peer channel join -b mychannel.block
#	peer chaincode install -n chaincode -v 1.0 -p github.com/hyperledger/fabric/peer/chaincode
	
	echo "----------------- peer0org2 -----------------"
	CORE_PEER_LOCALMSPID=Org2MSP
	CORE_PEER_ADDRESS=peer0.org2.example.com:7051 
	CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
	CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key
	CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
	
	peer channel join -b mychannel.block
	peer chaincode install -n chaincode -v 1.0 -p github.com/hyperledger/fabric/peer/chaincode
	echo "----------------- peer1org2 -----------------"
	
	CORE_PEER_ADDRESS=peer1.org2.example.com:7051
	CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/server.crt
	CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/server.key
	CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt

	peer channel join -b mychannel.block
	peer chaincode install -n chaincode -v 1.0 -p github.com/hyperledger/fabric/peer/chaincode
	echo "----------------- peer2org2 -----------------"
	CORE_PEER_ADDRESS=peer2.org2.example.com:7051
	CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer2.org2.example.com/tls/server.crt
	CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer2.org2.example.com/tls/server.key
	CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer2.org2.example.com/tls/ca.crt
	
	peer channel join -b mychannel.block
	peer chaincode install -n chaincode -v 1.0 -p github.com/hyperledger/fabric/peer/chaincode

	CORE_PEER_LOCALMSPID=Org1MSP
	CORE_PEER_ADDRESS=peer3.org1.example.com:7051
	CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer3.org1.example.com/tls/server.crt
	CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer3.org1.example.com/tls/server.key
	CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer3.org1.example.com/tls/ca.crt
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
}

echo "===================================================================="
echo "======================== Setup Chaincode ==========================="
echo "===================================================================="

peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
sleep 1
peer channel join -b mychannel.block
sleep 1
peer chaincode install -n chaincode -v 1.0 -p github.com/hyperledger/fabric/peer/chaincode
sleep 1
peer chaincode instantiate -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt -C $CHANNEL_NAME -n chaincode -v 1.0  -c '{"Args":["init","a","100","b","100"]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
sleep 10

peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt  -C mychannel -n chaincode -v 1.0  -c '{"Args":["Set","ubuntu", "100000"]}'
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt  -C mychannel -n chaincode -v 1.0  -c '{"Args":["Set","node0", "100000"]}'
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt  -C mychannel -n chaincode -v 1.0  -c '{"Args":["Set","node1", "100000"]}'
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt  -C mychannel -n chaincode -v 1.0  -c '{"Args":["Set","node2", "100000"]}'
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt  -C mychannel -n chaincode -v 1.0  -c '{"Args":["Set","node3", "100000"]}'
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt  -C mychannel -n chaincode -v 1.0  -c '{"Args":["Set","node4", "100000"]}'
sleep 1

channelJoin

echo "===================================================================="
echo "==================== Finished instantiating  ======================="
echo "===================================================================="

