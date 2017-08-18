package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"time"

	"github.com/hyperledger/fabric-sdk-go/api"
	"github.com/hyperledger/fabric-sdk-go/def/fabapi"
	"github.com/hyperledger/fabric-sdk-go/pkg/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabric-client/events"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabric-client/orderer"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabric-client/peer"
	fabrictxn "github.com/hyperledger/fabric-sdk-go/pkg/fabric-txn"
	"github.com/hyperledger/fabric/bccsp/factory"
	yaml "gopkg.in/yaml.v2"
)

type Connexion struct {
	User struct {
		Name            string `yaml:"name"`
		SkipPersistence bool   `yaml:"skipPersistence"`
		KeyPath         string `yaml:"keyPath"`
		CertPath        string `yaml:"certPath"`
		StatestorePath  string `yaml:"statestorePath"`
	}
	Peer struct {
		Org        string `yaml:"org"`
		peerOrgMSP string `yaml:"mspOrg"`
		BaseUrl    string `yaml:"baseUrl"`
		CertPath   string `yaml:"certPath"`
		Hostname   string `yaml:"hostname"`
		EventUrl   string `yaml:"eventUrl"`
	}

	ChannelName   string `yaml:"channelName"`
	ChaincodeName string `yaml:"chaincodeName"`

	Orderer struct {
		Url      string `yaml:"url"`
		CertPath string `yaml:"certPath"`
		Hostname string `yaml:"hostname"`
	}
}

// YAML content structured
var Conn Connexion

// Needed for the fabric-sdk-go tu work
func init() {
	factory.InitFactories(&factory.FactoryOpts{ProviderName: "SW"})
}

// initClientAndPeer returns the client and peer initialized
func initClientAndPeer() (api.FabricClient, api.Peer, error) {
	//Getting connexion information from connexion.yaml
	connexionFile, err := ioutil.ReadFile("./config/config.yaml")
	if err != nil {
		return nil, nil, fmt.Errorf("1_0_0 Couldn't read ./config/config.yaml :  %v", err)
	}

	err = yaml.Unmarshal(connexionFile, &Conn)
	if err != nil {
		return nil, nil, fmt.Errorf("1_0_1 Couldn't unmarshal ./config/config.yaml : %v", err)
	}

	// Getting informations from the fabric-sdk-go config file
	config, err := config.InitConfig("./config/config.yaml")
	if err != nil {
		return nil, nil, fmt.Errorf("1_0_2  Couldn't initialize config from ./config/config.yaml : %v", err)
	}

	//Initializing client and peer
	client, err := fabapi.NewClientWithPreEnrolledUser(config, Conn.User.StatestorePath, Conn.User.SkipPersistence, Conn.User.Name, Conn.User.KeyPath, Conn.User.CertPath, Conn.Peer.Org)
	if err != nil {
		return nil, nil, fmt.Errorf("1_0_3 Couldn't  create the user : %v", err)
	}

	peer, err := peer.NewPeerTLSFromCert(Conn.Peer.BaseUrl, Conn.Peer.CertPath, Conn.Peer.Hostname, config)
	if err != nil {
		return nil, nil, fmt.Errorf("1_0_4 Couldn't create peer : %v", err)
	}

	return client, peer, nil
}

//initClientPeerAndChannel adds the channel configuration
func initClientPeerAndChannel() (api.FabricClient, api.Peer, api.Channel, error) {
	//Initializing client, peer and channel
	client, peer, err := initClientAndPeer()
	if err != nil {
		return nil, nil, nil, fmt.Errorf("1_1_0 Couldn't init client and/or peer: %v", err)
	}

	channel, err := client.NewChannel(Conn.ChannelName)
	if err != nil {
		return nil, nil, nil, fmt.Errorf("1_1_1 Couldn't instantiate the channel sunchain: %v", err)
	}

	//Adding peer and set him to primary
	err = channel.AddPeer(peer)
	if err != nil {
		return nil, nil, nil, fmt.Errorf("1_1_2 Couldn't add the peer to the channel: %v", err)
	}
	err = channel.SetPrimaryPeer(peer)
	if err != nil {
		return nil, nil, nil, fmt.Errorf("1_1_3 Couldn't set the channel's primary peer: %v", err)
	}
	return client, peer, channel, nil
}

//initClientPeerChannelAndEventHub adds the orderer and eventhub configuration
func initClientPeerChannelAndEventHub() (api.FabricClient, api.Peer, api.Channel, api.EventHub, error) {
	//Initializing client, peer channel and eventhub
	client, peer, channel, err := initClientPeerAndChannel()
	if err != nil {
		return nil, nil, nil, nil, fmt.Errorf("1_2_0 Couldn't init client, peer and channel : %v", err)
	}

	eventHub, err := events.NewEventHub(client)
	if err != nil {
		return nil, nil, nil, nil, fmt.Errorf("1_2_1 Couldn't create a blank event hub: %v", err)
	}

	//Adding the peer configuration to the eventhub
	eventHub.SetPeerAddr(Conn.Peer.EventUrl, Conn.Peer.CertPath, Conn.Peer.Hostname)
	for i := 0; err != nil && i < 3; i++ {
		err = eventHub.Connect()
	}
	if err != nil {
		return nil, nil, nil, nil, fmt.Errorf("1_2_2 Couldn't connect to the event hub: %v", err)
	}

	//Initializing the orderer and putting him in the channel configuration
	ordr, err := orderer.NewOrderer(Conn.Orderer.Url, Conn.Orderer.CertPath, Conn.Orderer.Hostname, client.GetConfig())

	channel.AddOrderer(ordr)

	return client, peer, channel, eventHub, nil
}

func Transaction(index1 string, index2 string, value int) error {
	client, peer, channel, eventHub, err := initClientPeerChannelAndEventHub()
	if err != nil {
		return fmt.Errorf("1_3_1 Couldn't init client, peer and/or channel: %s", err)
	}

	err = fabrictxn.InvokeChaincode(client, channel, []api.Peer{peer}, eventHub, Conn.ChaincodeName, []string{"Transaction", index1, index2, strconv.Itoa(value)}, map[string][]byte{})
	if err != nil {
		return fmt.Errorf("1_3_2 Couldn't invoke the chaincode: %v", err)
	}
	return nil
}

func main() {
	for {
		fmt.Printf("Transaction 1 asked ")
		Transaction("ubuntu", "node0", 10)
		fmt.Printf("Transaction 2 asked\n")
		Transaction("node0", "ubuntu", 10)
		time.Sleep(7 * time.Second)
	}
}
