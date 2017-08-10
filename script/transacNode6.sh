#!/bin/bash

peer chaincode invoke --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt  -C $CHANNEL_NAME -n chaincode -v 1.0  -c '{"Args":["Set","node6", 100000]}'

while : ; do
	peer chaincode invoke --tls $CORE_PEER_TLS_ENABLED --cafile ./ca.crt  -C $CHANNEL_NAME -n chaincode -v 1.0  -c '{"Args":["Transaction", "node4","node6", 10]}'
	peer chaincode invoke --tls $CORE_PEER_TLS_ENABLED --cafile ./ca.crt  -C $CHANNEL_NAME -n chaincode -v 1.0  -c '{"Args":["Transaction", "node3","node6", 10]}'
	sleep 7
done
