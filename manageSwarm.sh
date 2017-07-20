#!/bin/bash

COMMAND="$1"

function printHelp {
    echo "Usage : ./manageSwarm < swarm-up|up|start|stop|down|swarm-down > if up, creates certificates and gives it to the other swarm members, then starts the service. If down, suppresses all that."
    echo "start exports only the containers on each peer, stops removes them and cleans without stopping the swarm or removing the certificates"
    echo "swarm-up and swarm-down respectively initiate the swarm or removes it"
}

function swarm-init {

    echo
    echo
    echo "----- Creating swarm and duplicating keys ------"
    echo
    echo

    docker swarm init > ./joinCommand
    sed -i '1,4d' ./joinCommand && sed -i '4,7d' ./joinCommand
    chmod a+x ./joinCommand

    for i in {ec2,ec3}; do
    ssh -q "$i" exit
    if [ "$?" = '0' ];then
            echo "$i is up"
            scp ./joinCommand "$i":~
            ssh "$i" './joinCommand'
            ssh "$i" 'rm ./joinCommand'
    else
     	echo "$?  - $i is down"
    fi
    done
    rm ./joinCommand

}

function init {
    
    echo
    echo
    echo "================================================"
    echo "============= Initializing nodes ==============="
    echo "================================================"
    echo
    echo
    echo "------------- Generating artifacts -------------"
    echo
    echo

    ./generateArtifacts.sh
    for i in {ec2,ec3}; do
    ssh -q "$i" exit
    if [ "$?" = '0' ];then
            echo "$i is up"
            scp -r ./crypto-config "$i":~/hyperledger/testing/
            scp -r ./channel-artifacts/ "$i":~/hyperledger/testing/
    else
     	echo "$?  - $i is down"
    fi
    done

    echo "------------- Deploying hyperledger ------------"
    docker network create --driver=overlay --attachable testing_sunchain_default
    docker stack deploy -c docker-compose.yaml testing_sunchain 	
    sleep 1
    docker exec -it $(docker ps -f name=testing_sunchain_cli --format "{{ .Names }}") './script/script.sh'
    docker service rm testing_sunchain_cli 
}

function start {
    echo "------------- Deploying hyperledger ------------"
    docker network create --driver=overlay --attachable testing_sunchain_default
    docker stack deploy -c docker-compose.yaml testing_sunchain
    sleep 1
    docker exec -it $(docker ps -f name=testing_sunchain_cli --format "{{ .Names }}") './script/script.sh' 
    docker service rm testing_sunchain_cli 
}

function stop {
    echo "------------ Stopping hyperledger --------------"
    docker service rm testing_sunchain_peer0 testing_sunchain_peer1 testing_sunchain_peer2 testing_sunchain_orderer 
    CHAINCONTAINERS=$(docker ps -f name=sunchaincode --format "{{ .Names }}")
    echo $CHAINCONTAINERS
    CHAINIMAGES=$(docker images *sunchaincode* -q)
    echo $CHAINIMAGES
    if [[ $CHAINCONTAINERS ]];then
    	docker rm -f $(docker ps -f name=sunchaincode --format "{{ .Names }}")
    fi
    if [[  $CHAINIMAGES ]];then
    	docker rmi -f $(docker images *sunchaincode* -q)
    fi
    docker network prune -f
    docker volume prune -f
}

function terminate {
    echo "================================================"
    echo "============ Terminating nodes ================="
    echo "================================================"
    echo
    echo
    echo "-------- Stopping hyperledger services ---------"
    echo
    echo

    docker service rm testing_sunchain_peer0 testing_sunchain_peer1 testing_sunchain_peer2 testing_sunchain_orderer 
    CHAINCONTAINERS=$(docker ps -f name=sunchaincode --format "{{ .Names }}")
    echo $CHAINCONTAINERS
    CHAINIMAGES=$(docker images *sunchaincode* -q)
    echo $CHAINIMAGES
    if [[ $CHAINCONTAINERS ]];then
    	docker rm -f $(docker ps -f name=sunchaincode --format "{{ .Names }}")
    fi
    if [[  $CHAINIMAGES ]];then
    	docker rmi -f $(docker images *sunchaincode* -q)
    fi
    rm -r crypto-config/ channel-artifacts/
    docker network prune -f
    docker volume prune -f
    for i in {ec2,ec3}; do
    ssh -q "$i" exit
    if [ "$?" = '0' ];then
        echo "$i is up"
        ssh "$i" 'rm -r hyperledger/testing/crypto-config hyperledger/testing/channel-artifacts'
    else
        echo "$? - $i is down"
    fi
    done
 
}

function swarm-down {

    echo
    echo "--------------- Removing swarm ----------------"
    echo
    echo

    for i in {ec2,ec3}; do
    ssh -q "$i" exit
    if [ "$?" = '0' ];then
        echo "$i is up"
        ssh "$i" 'docker swarm leave'
    else
        echo "$? - $i is down"
    fi
    done
    docker swarm leave --force
}

if [ "$COMMAND" = 'swarm-init' ];then
	swarm-up
elif [ "$COMMAND" = 'up' ];then
	init
elif [ "$COMMAND" = 'start' ];then
	start
elif [ "$COMMAND" = 'stop' ];then
	stop
elif [ "$COMMAND" = 'down' ];then
	terminate
elif [ "$COMMAND" = 'swarm-down' ];then
	swarm-down
else
	printHelp
fi
