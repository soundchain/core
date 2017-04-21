pragma solidity ^0.4.4;

// This contract implements tokenFallback function.
// This will prevent accidentally sent tokens from being accepted by wrong contract.
// It will also allow to handle incoming token transactions similar to Ether transactions.
contract ReceiverInterface { 
    function tokenFallback(address _from, uint _value, bytes _data){
        //Incoming transaction code here
    }
}