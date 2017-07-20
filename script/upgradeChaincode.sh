#!/bin/bash

VERSION="$1"

function printHelp {
	echo "Usage : ./upgradeChaincode <x.y> requires an argument, the version we want the chaincode to be upgraded to, and upgrades the sunchaincode accordingly"
}

function upgradeChaincode {
	echo "===================================================================="
	echo "========== Installing new version of sunchain chaincode ============"
	echo "===================================================================="

	peer chaincode install -n sunchaincode -v $VERSION -p github.com/hyperledger/fabric/peer/sunchaincode 
	sleep 3

	echo "===================================================================="
	echo "====================== Upgrading chaincode ========================="
	echo "===================================================================="

	peer chaincode upgrade -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt -C $CHANNEL_NAME -n sunchaincode -v $VERSION  -c '{"Args":["init"]}' -P "OR ('Org1MSP.member','Org2MSP.member')"

	echo "===================================================================="
	echo "====================== Finished upgrading  ========================="
	echo "===================================================================="
}

if [[ "$1" =~ ^[0-9].[0-9] ]];then
	upgradeChaincode $1
else 
	printHelp 
fi
