#!/bin/bash +x

CHANNEL_NAME=$1
: ${CHANNEL_NAME:="sunchain"}
export FABRIC_CFG_PATH=$PWD
mkdir -p channel-artifacts
echo

function generateCerts (){
	CRYPTOGEN=./bin/cryptogen
	echo
	echo "##########################################################"
	echo "##### Generate certificates using cryptogen tool #########"
	echo "##########################################################"
	$CRYPTOGEN generate --config=./crypto-config.yaml
	echo
}

function generateChannelArtifacts() {
	CONFIGTXGEN=./bin/configtxgen
	echo "##########################################################"
	echo "#########  Generating Orderer Genesis block ##############"
	echo "##########################################################"
	$CONFIGTXGEN -profile Genesis -outputBlock ./channel-artifacts/genesis.block

	echo
	echo "#################################################################"
	echo "### Generating channel configuration transaction 'channel.tx' ###"
	echo "#################################################################"
	$CONFIGTXGEN -profile Channel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
}

generateCerts
generateChannelArtifacts

