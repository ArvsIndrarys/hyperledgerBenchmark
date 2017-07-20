# Configuration on the Swarm manager

All that is needed is here . On the other nodes of the swarm, the only thing needed is to have a folder ~/hyperledger

## HowTo

Simply use ./manager start to make the deployment, it does all the work for you (you're welcome).
It will transmit the critical informations on the other nodes, deploy the containers, create a channel, put peer0 on it, and instantiates the chaincode.
To put new informations in the chaincode, use the rpi-client. As it is written in go, it will work everywhere (tests done on ec1, an Ubuntu and an rpi).

## Modifications

If the structure changes you will have to :

* if it is about adding/removing physical machines (like a new ec2 instance), adapt the manageSwarm file
* if it is about adding/removing peer, orderers, ... (all hyperledger structure related changes) adapt the docker-compose.yaml and reflect these changes in the crypt-config.yaml and configtx.yaml (documentation is on github/hyperledger/fabric)
* if it is about CA changes, adapt crypto-config.yaml and configtx.yaml

> Remember that all changes made will surely have an impact on how the client works (new certs and/or privateKeys, ...)

