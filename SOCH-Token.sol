pragma solidity ^0.4.9;

import "./ReceiverInterface.sol";
import "./ERC23Interface.sol";

contract SOCHToken is ERC23 {
    
    // Called when tokens moves between addresses
    event Transfer(address indexed from, address indexed to, uint value);
    
    
    // Total amount of issued tokens
    uint256 public totalSupply;

    // Contract Name 
    string public name="SoundChain token";

    // Contract Symbol
    string public symbol="SOCH";

    // Contract decimals
    uint public decimals=16;

    // Balance of the accounts
    mapping (address => uint256) public balances;
    
    address public owner;

    //////////////////////////////////////////////////////////////////
    // PUBLIC METHODS
    //////////////////////////////////////////////////////////////////

    //  The contract can be initialized with a number of tokens
    //  All the tokens are deposited to the owner address
    //
    // @param _balance Initial supply of the contract
    // @param _name Token Name
    // @param _symbol Token symbol
    // @param _decimals Token decimals
    function SOCHToken(uint256 _initialSupply, string _name, string _symbol, uint _decimals){
        totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[owner] = _initialSupply;
    }

    // Return the balance of a specified address
    function balanceOf(address addr) public constant returns (uint256) {
        return balances[addr];
    }

    // Returns the total amount of issued tokens
    function totalSupply() public constant returns  (uint256 total) {
        return totalSupply;
    }

    // ERC20 default transfer function that is called without data by some UI wallets
    // @param to address to move funds to
    // @param amount number of tokens to move
    function transfer(address _to, uint256 _amount) returns (bool){
        bytes memory emptyData;
        if(isContract(_to)) {
            return transferToContract(_to, _amount, emptyData);
        }
        else {
            return transferToAddress(_to, _amount, emptyData);
        }
    }
    
    // Transfer owned tokens to another address
    // @param to address to move funds to
    // @param amount number of tokens to move
    // @param data special data that can be attached to transactions (could be empty)
    function transfer(address _to, uint256 _amount, bytes _data) returns (bool){
        if(isContract(_to)) {
            return transferToContract(_to, _amount, _data);
        }
        else {
            return transferToAddress(_to, _amount, _data);
        }
    }
    
    function tokenFallback(address _from, uint _amount, bytes _data) returns (bool) {
        throw;
    }
    
    
    // Check if the receiver is a contract or an address
    // when transferring tokens.
    // @param _addr address that needs to be checked
    function isContract(address _addr) private constant returns (bool is_contract) {
        uint length;
        assembly {
            //Retrieve the size of the code on target address, this needs assembly
            //if there is no code length will be 0.
            length := extcodesize(_addr)
        }
        if(length>0) {
            return true;
        }
        else {
            return false;
        }
    }
    
    // Private function that actually move the tokens between addresses
    // @param _to destination address
    // @param _amount token to be transferred
    // @param _data bytes data attached (could be empty)
    function transferToAddress(address _to, uint _amount, bytes _data) private returns (bool success) {
        if(balances[msg.sender] >= _amount && balances[_to] + _amount >= balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }
    
    // Private function that actually move the tokens between address and contract
    // @param _to destination address
    // @param _amount token to be transferred
    // @param _data bytes data attached (could be empty)
    function transferToContract(address _to, uint _amount, bytes _data) private returns (bool success) {
        if(balances[msg.sender] >= _amount && balances[_to] + _amount >= balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            ReceiverInterface reciever = ReceiverInterface(_to);
            reciever.tokenFallback(msg.sender, _amount, _data);
            Transfer(msg.sender, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }
}