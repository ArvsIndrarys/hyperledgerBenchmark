package main

import (
	"fmt"
	"log"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

// SimpleChaincode example simple Chaincode implementation
type SimpleChaincode struct{}

//Initialization step
func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	log.Printf("--> INITIALIZING")
	return shim.Success(nil)
}

//Query gets the value of the index given
// global so returns a success or error code with the payload containing the error or the value of the index
func Query(stub shim.ChaincodeStubInterface, index string) pb.Response {
	log.Printf("--> QUERY")
	if a, err := stub.GetState(index); err != nil {
		return shim.Error("0_0_0 " + err.Error())
	} else {
		log.Printf("    %s : %s", index, a)
		log.Printf("    END Query")
		return shim.Success([]byte(a))
	}
}

// Set creates or update the index with the value given
// global so returns a success or error code with the payload containing the error or the index and new value
func Set(stub shim.ChaincodeStubInterface, index string, value int) pb.Response {
	log.Printf("--> SET")
	if err := stub.PutState(index, []byte(strconv.Itoa(value))); err != nil {
		return shim.Error("0_1_0 " + err.Error())
	}
	response := index + ": " + strconv.Itoa(value)
	log.Printf("    %s", response)
	log.Printf("    END SET")
	return shim.Success([]byte(response))
}

//add adds the value to the index
// returns the new value or the error created
func add(stub shim.ChaincodeStubInterface, index string, value int) (int, error) {
	log.Printf("-----> Add")
	a, err := stub.GetState(index)
	if err != nil {
		return 0, fmt.Errorf("0_2_0 Couldn't access the state of %s : %s", index, err)
	}
	log.Printf("       Value of %s before modification : %s", index, a)
	aInt, err := strconv.Atoi(string(a))
	if err != nil {
		return 0, fmt.Errorf("0_2_1 Couldn't set the value to int : %s", err)
	}
	newA := value + aInt
	if err := stub.PutState("a", []byte(strconv.Itoa(newA))); err != nil {
		return 0, fmt.Errorf("0_2_2 Couldn't put the value into the new state : %s", err)
	}
	log.Printf("       Value of the index after modification : %d", newA)
	log.Printf("       END Add")
	return newA, nil
}

//substract substracts the value to the index
// returns the value or the error created
func substract(stub shim.ChaincodeStubInterface, index string, value int) (int, error) {
	log.Printf("-----> Substract")
	a, err := stub.GetState(index)
	if err != nil {
		return 0, fmt.Errorf("0_3_0 Couldn't access the state of %s : %s", index, err)
	}
	log.Printf("       Value of the index %s before modification : %s", index, a)
	aInt, err := strconv.Atoi(string(a))
	if err != nil {
		return 0, fmt.Errorf("0_3_1 Couldn't transform the value to int : %s", err)
	}
	newA := aInt - value
	if newA > 0 {
		if err := stub.PutState(index, []byte(strconv.Itoa(newA))); err != nil {
			return 0, fmt.Errorf("0_3_2 Couldn't write the new value in the chaincode : s%s", err)
		}
		log.Printf("        Value of the index after modification : %d", newA)
		log.Printf("        END Substract")
		return newA, nil
	}
	return 0, fmt.Errorf("0/3/4 Couldn't substract as not enough token")
}

// Transaction transfers the value from index1 to index2
// global so returns a success or error code with a payload containing the error or the new values of the indexes
func Transaction(stub shim.ChaincodeStubInterface, index1 string, index2 string, value int) pb.Response {
	log.Printf("--> TRANSACTION")
	val1, err := substract(stub, index1, value)
	if err != nil {
		return shim.Error("0_4_0 " + err.Error())
	}

	val2, err := add(stub, index2, value)
	if err != nil {
		return shim.Error("0_4_1 " + err.Error())
	}
	response := index1 + ": " + strconv.Itoa(val1) + " and " + index2 + ": " + strconv.Itoa(val2)
	fmt.Printf("    %s", response)
	fmt.Printf("    END TRANSACTION")
	return shim.Success([]byte(response))
}

// Invoke is the gateway of the chaincode, verifying the arguments given and calling the right function
// transmits the results of the global functions or an error of bad call
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
			return shim.Error("0_I_0" + err.Error())
		}
		return Set(stub, index, value)
	case "Transaction":
		index1 := args[0]
		index2 := args[1]
		value, err := strconv.Atoi(args[2])
		if err != nil {
			return shim.Error("0_I_1 " + err.Error())
		}
		return Transaction(stub, index1, index2, value)
	default:
		return shim.Error("0_I_2 Wrong function in parameters : Set(string, int) Transaction(string, string, int) are available")
	}
}

// Simply launches the chaincode
func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("O_S_0 Error starting Simple chaincode: %s", err)
	}
}
