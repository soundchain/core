pragma solidity ^0.4.4;

contract ERC23 {
  uint public totalSupply;
  uint public decimals;
  function balanceOf(address who) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transfer(address to, uint value, bytes data) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
}