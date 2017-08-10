package main

import (
	"encoding/json"
	"testing"

	"github.com/hyperledger/fabric/core/chaincode/shim"
)

func TestQuery(t *testing.T) {
	s := shim.NewMockStub("mockStub", &SimpleChaincode{})
	if s == nil {
		t.Fatalf("Mock Stub creation failed.")
	}
	s.MockTransactionStart("a1")
	defer s.MockTransactionEnd("a1")
	r := Set(s, "a", 12345)
	if r = Query(s, "a"); r.Status == shim.ERROR {
		t.Fatalf("Couldn't retrieve the value of a")
	} else {
		a := 0
		if err := json.Unmarshal(r.Payload, &a); err != nil {
			t.Fatalf("Couldn't unmarshal the blockhain's response ! %s", err)
		}
		if a != 12345 {
			t.Fatalf("Wrong value of a has been received : %d", a)
		}
	}
}

func TestTransaction(t *testing.T) {
	s := shim.NewMockStub("mockStub", &SimpleChaincode{})
	if s == nil {
		t.Fatalf("Mock Stub creation failed.")
	}
	s.MockTransactionStart("a1")
	defer s.MockTransactionEnd("a1")
	r := Set(s, "a", 12345)
	r = Set(s, "b", 54321)
	if r = Transaction(s, "a", "b", 57); r.Status == shim.ERROR {
		t.Fatalf("Couldn't make the transaction")
	}
}
