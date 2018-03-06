#!/bin/bash

COMMAND="$1"

# print help if wrong option is used
function printHelp {
    echo "Usage : ./manageSwarm < swarm-up|up|start|stop|down|swarm-down > if up, creates certificates and gives it to the other swarm members, then starts the service. If down, suppresses all that."
    echo "start exports only the containers on each peer, stops removes them and cleans without stopping the swarm or removing the certificates"
    echo "swarm-up and swarm-down respectively initiate the swarm or removes it"
}

# swarm propagation
function swarm-up {
    echo "----- Creating swarm and duplicating keys ------"
    docker swarm init > ./joinCommand
   sed -i '1,4d' ./joinCommand && sed -i '4,7d' ./joinCommand
   chmod a+x ./joinCommand

   for i in {node0,node1,node2,node3,node4,node6}; do
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

# artifacts creation ( certs and blockchain's init data ) and propagation to all nodes if they are up
# then call to the script that creates all blockchain components
function up {
    echo "================================================"
    echo "============= Initializing nodes ==============="
    echo "================================================"
    echo "------------- Generating artifacts -------------"

    ./generateArtifacts.sh
   for i in {node0,node1,node2,node3,node4,node6}; do
   ssh -q "$i" exit
   if [ "$?" = '0' ];then
           echo "$i is up"
           scp -r ./crypto-config "$i":~/hyperledgerBenchmark
           scp -r ./channel-artifacts/ "$i":~/hyperledgerBenchmark
   else
    	echo "$?  - $i is down"
   fi
   done

   start
}

# if we didn't fully removed the blockchain (certs, channel artifacts and data) launch it back
function start {
    echo "------------- Deploying hyperledger ------------"
    docker network create --driver=overlay --attachable hyperledgerBenchmark_default
    docker stack deploy -c docker-compose.yaml hyperledgerBenchmark
    sleep 1
    docker exec -it $(docker ps -f name=hyperledgerBenchmark_cli --format "{{ .Names }}") './script/script.sh' 
}

# just stopping the blockchain
function stop {
    echo "------------ Stopping hyperledger --------------"
    docker stack rm  hyperledgerBenchmark
	docker stop $(docker ps -a -f name='dev*' -q)
	docker rm $(docker ps -a -f name='dev*' -q)
	docker rmi $(docker images -f reference='*chaincode*' -q)
	
	for i in {node0,node1,node2,node3,node4,node6};do 
	ssh -q "$i" exit
	if [ "$?" = '0' ];then
    	echo "$i is up"
		ssh "$i" 'docker stop $(docker ps -a -f name='dev*' -q); docker rm $(docker ps -a -f name='dev*' -q); docker rmi $(docker images -f reference='*chaincode*' -q)'
	else
    	echo "$? - $i is down"
	fi
	done
    docker network prune -f
    docker volume prune -f
}

# full blockchain removal (with certs and channel-artifacts)
function terminate {
    echo "================================================"
    echo "============ Terminating nodes ================="
    echo "================================================"
    echo "-------- Stopping hyperledger services ---------"

   stop
   for i in {node0,node1,node2,node3,node4,node6};do 
   ssh -q "$i" exit
   if [ "$?" = '0' ];then
       echo "$i is up"
       ssh "$i" 'rm -r hyperledgerBenchmark/crypto-config hyperledgerBenchmark/channel-artifacts'
   else
       echo "$? - $i is down"
   fi
   done
}

# swarm destruction
function swarm-down {
    echo "--------------- Removing swarm ----------------"

   for i in {node0,node1,node2,node3,node4,node6}; do
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

# On gère ici quelle commande peut être appellée pour pouvoir agir
if [ "$COMMAND" = 'swarm-up' ];then
	swarm-up
elif [ "$COMMAND" = 'up' ];then
	up
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
