#!/bin/bash

COMMAND="$1"

# On affiche ces indications si le script est mal appelé
function printHelp {
    echo "Usage : ./manageSwarm < swarm-up|up|start|stop|down|swarm-down > if up, creates certificates and gives it to the other swarm members, then starts the service. If down, suppresses all that."
    echo "start exports only the containers on each peer, stops removes them and cleans without stopping the swarm or removing the certificates"
    echo "swarm-up and swarm-down respectively initiate the swarm or removes it"
}

# On initialize le swarm en propageant la commande contenant un token auto-généré puis en lançant cette commande
function swarm-up {

    echo
    echo
    echo "----- Creating swarm and duplicating keys ------"
    echo
    echo

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

# On crée les artifacts - certificats (blockchain privée) et donnée d'initialisation de la blockchain - à chaque noeud s'il est up
# Puis on lance le script docker qui lance tout les containers (peers) puis la blockchain en elle même
function up {
    
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

    echo "------------- Deploying hyperledger ------------"
    docker network create --driver=overlay --attachable hyperledgerBenchmark_default
    docker stack deploy -c docker-compose.yaml hyperledgerBenchmark 	
    sleep 1
    docker exec -it $(docker ps -f name=hyperledgerBenchmark_cli --format "{{ .Names }}") './script/script.sh'
}

# Dans le cas où on a stoppé la blockchain sans supprimer les données de départ, on ne fait que relancer Docker
# Utile pour les modifications d'appoint et pour éviter des dialogues réseau inutiles
function start {
    echo "------------- Deploying hyperledger ------------"
    docker network create --driver=overlay --attachable hyperledgerBenchmark_default
    docker stack deploy -c docker-compose.yaml hyperledgerBenchmark
    sleep 1
    docker exec -it $(docker ps -f name=hyperledgerBenchmark_cli --format "{{ .Names }}") './script/script.sh' 
}

#On arrête la blockchain sans supprimer les données initiales ou les certificats
#Utile pour les modifications d'appoint
function stop {
    echo "------------ Stopping hyperledger --------------"
    docker service rm hyperledgerBenchmark_cli hyperledgerBenchmark_peer0org1 hyperledgerBenchmark_peer1org1 hyperledgerBenchmark_peer2org1 hyperledgerBenchmark_peer3org1 hyperledgerBenchmark_peer4org1 hyperledgerBenchmark_peer5org1 hyperledgerBenchmark_peer6org1 hyperledgerBenchmark_orderer 
	docker stop $(docker ps -a -f name='dev*' -q); docker rm $(docker ps -a -f name='dev*' -q); docker rmi $(docker images -f reference='*chaincode*' -q)
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

#On supprime tout ce qui a été fait au niveau de la blockchain. Relancer le script avec un up aura changé toutes les données auto-générées (données initiales et certificats)
function terminate {
    echo "================================================"
    echo "============ Terminating nodes ================="
    echo "================================================"
    echo
    echo
    echo "-------- Stopping hyperledger services ---------"
    echo
    echo

    docker service rm hyperledgerBenchmark_cli hyperledgerBenchmark_peer0org1 hyperledgerBenchmark_peer1org1 hyperledgerBenchmark_peer2org1 hyperledgerBenchmark_peer3org1 hyperledgerBenchmark_peer4org1 hyperledgerBenchmark_peer5org1 hyperledgerBenchmark_peer6org1 hyperledgerBenchmark_orderer 
	docker stop $(docker ps -a -f name='dev*' -q); docker rm $(docker ps -a -f name='dev*' -q); docker rmi $(docker images -f reference='*chaincode*' -q)
    rm -r crypto-config/ channel-artifacts/
    docker network prune -f
    docker volume prune -f
   for i in {node0,node1,node2,node3,node4,node6};do 
   ssh -q "$i" exit
   if [ "$?" = '0' ];then
       echo "$i is up"
       ssh "$i" 'rm -r hyperledgerBenchmark/crypto-config hyperledgerBenchmark/channel-artifacts'
   	ssh "$i" 'docker stop $(docker ps -a -f name='dev*' -q); docker rm $(docker ps -a -f name='dev*' -q); docker rmi $(docker images -f reference='*chaincode*' -q)'
   else
       echo "$? - $i is down"
   fi
   done
}

#On retire chacun des noeuds du swarm avant de le supprimer
function swarm-down {

    echo
    echo "--------------- Removing swarm ----------------"
    echo
    echo

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
