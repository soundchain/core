pragma solidity ^0.4.9;

import "./ReceiverInterface.sol";
import "./ERC23Interface.sol";

contract SoundTokens {
    
    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }
    
    // Called when tokens moves between addresses
    event Transfer(address indexed from, address indexed to, uint value);
    
    
    // Total amount of issued tokens
    uint256 _totalSupply;
    
    
    // Total amount of SOCH received. Needed for dividends calculating.
    uint256 _totalIncome;

    // Contract Name 
    string public name;

    // Contract Symbol
    string public symbol;

    // Contract decimals
    int public decimals;

    // Balance of the accounts
    mapping (address => uint256) public balances;
    mapping (address => uint256) public paid;
    
    address public owner;
    address public SOCHContract;

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
    function SoundTokens(uint256 _initialSupply, string _name, string _symbol, int _decimals){
        _totalSupply = _initialSupply;
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
        return _totalSupply;
    }

   
   function changeSOCH(address _newSOCH) onlyOwner {
       SOCHContract = _newSOCH;
   }

    // ERC20 default transfer function that is called without data by some UI wallets
    // @param to address to move funds to
    // @param amount number of tokens to move
    function transfer(address _to, uint256 _amount) returns (bool){
        //TODO
        paid[msg.sender] -= _amount / balances[msg.sender] * paid[msg.sender];
        paid[_to] += _amount  / balances[msg.sender] * paid[msg.sender];
        
        
        
        
        
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
        
        //TODO
        paid[msg.sender] -= _amount / balances[msg.sender] * paid[msg.sender];
        paid[_to] += _amount  / balances[msg.sender] * paid[msg.sender];
        
        
        
        if(isContract(_to)) {
            return transferToContract(_to, _amount, _data);
        }
        else {
            return transferToAddress(_to, _amount, _data);
        }
    }
    
    //TODO test this function.
    function DEBUG_getDividends(address _addr) constant returns (uint256){
        return ((_totalIncome * (balances[_addr]/_totalSupply)) - paid[_addr]);
    }
    
    
    
    // Function to claim dividends.
    function claimMyDividends() {
        // balances[msg.sender)/_totalSupply => percent of tokens held by msg.sender
        // 
        // (_totalIncome * (balances[msg.sender)/_totalSupply) - paid[msg.sender]) => amount we need to pay
        //
        ERC23 SOCH = ERC23(SOCHContract);
        
        if(SOCH.transfer(msg.sender, DEBUG_getDividends(msg.sender))) {
            paid[msg.sender] += DEBUG_getDividends(msg.sender);
        }
    }
    
    
    //////////////////////////////////////////////////////////////////
    // PRIVATE METHODS
    //////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    function tokenFallback(address _from, uint _amount, bytes _data) returns (bool) {
        //TODO
        if(msg.sender!=SOCHContract) { 
            throw;
        }
        _totalIncome += _amount;
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