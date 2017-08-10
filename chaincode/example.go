/*
Copyright IBM Corp. 2016 All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

//WARNING - this chaincode's ID is hard-coded in chaincode_example04 to illustrate one way of
//calling chaincode from a chaincode. If this example is modified, chaincode_example04.go has
//to be modified as well with the new ID of chaincode_example02.
//chaincode_example05 show's how chaincode ID can be passed in as a parameter instead of
//hard-coding.

import (
	"fmt"
	"log"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

// SimpleChaincode example simple Chaincode implementation
type SimpleChaincode struct{}

func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	log.Printf("--> INITIALIZING")
	return shim.Success([]byte("All is ok"))
}

func Query(stub shim.ChaincodeStubInterface, index string) pb.Response {
	if a, err := stub.GetState(index); err != nil {
		return shim.Error(err.Error())
	} else {
		log.Printf("a : %s", a)
		return shim.Success([]byte(a))
	}
}

func Set(stub shim.ChaincodeStubInterface, index string, value int) pb.Response {
	if err := stub.PutState(index, []byte(strconv.Itoa(value))); err != nil {
		return shim.Error(err.Error())
	}
	response := index + ": " + strconv.Itoa(value)
	return shim.Success([]byte(response))
}

func add(stub shim.ChaincodeStubInterface, index string, value int) (int, error) {
	a, err := stub.GetState(index)
	if err != nil {
		return 0, fmt.Errorf("Couldn't access the state of %s : %s", index, err)
	}
	log.Printf("Value of %s before modification : %s", index, a)
	aInt, err := strconv.Atoi(string(a))
	if err != nil {
		return 0, fmt.Errorf("Couldn't set the value to int : %s", err)
	}
	newA := value + aInt
	if err := stub.PutState("a", []byte(strconv.Itoa(newA))); err != nil {
		return 0, fmt.Errorf("Couldn't put the value into the new state : %s", err)
	}
	log.Printf("Value of the index after modification : %d", newA)
	return newA, nil
}

func substract(stub shim.ChaincodeStubInterface, index string, value int) (int, error) {
	a, err := stub.GetState(index)
	if err != nil {
		return 0, fmt.Errorf("Couldn't access the state of %s : %s", index, err)
	}
	log.Printf("Value of the index before modification : %s", a)
	aInt, err := strconv.Atoi(string(a))
	if err != nil {
		return 0, fmt.Errorf("Couldn't transform the value to int : %s", err)
	}
	newA := aInt - value
	if newA > 0 {
		if err := stub.PutState(index, []byte(strconv.Itoa(newA))); err != nil {
			return 0, fmt.Errorf("Couldn't write the new value in the chaincode : s%s", err)
		}
		log.Printf("Value of the index after modification : %d", newA)
		return newA, nil
	}
	return 0, fmt.Errorf("Couldn't substract as not enough token")
}

func Transaction(stub shim.ChaincodeStubInterface, index1 string, index2 string, value int) pb.Response {
	val1, err := substract(stub, index1, value)
	if err != nil {
		return shim.Error(err.Error())
	}

	val2, err := add(stub, index2, value)
	if err != nil {
		return shim.Error(err.Error())
	}
	response := index1 + ": " + strconv.Itoa(val1) + " and " + index2 + ": " + strconv.Itoa(val2)
	return shim.Success([]byte(response))
}

func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	switch function {
	case "Query":
		index := args[0]
		return Query(stub, index)
	case "Set":
		index := args[0]
		value, err := strconv.Atoi(args[1])
		if err != nil {
			return shim.Error(err.Error())
		}
		return Set(stub, index, value)
	case "Transaction":
		index1 := args[0]
		index2 := args[1]
		value, err := strconv.Atoi(args[3])
		if err != nil {
			return shim.Error(err.Error())
		}
		return Transaction(stub, index1, index2, value)
	default:
		return shim.Error("Wrong function in parameters : Add(s, int), Query(s), Substract(s,int) are available")
	}
}

func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}
