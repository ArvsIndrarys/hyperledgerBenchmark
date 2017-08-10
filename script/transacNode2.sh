#!/bin/bash

peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /ca.crt  -C mychannel -n chaincode -v 1.0  -c '{"Args":["Set","node2", "100000"]}'

while true
do
	peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /ca.crt  -C mychannel -n chaincode -v 1.0  -c '{"Args":["Transaction", "node1","node2", "10"]}'
	peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /ca.crt  -C mychannel -n chaincode -v 1.0  -c '{"Args":["Transaction", "node1","node2", "10"]}'
	sleep 7
done
