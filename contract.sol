pragma solidity ^0.4.10;

contract Bag{
    string Number;
    string Pnr;
    address User;
 
    enum AssetState { Complete }
 
    AssetState State;
 
    function Bag() {}

    function upload(address user, string number,string pnr) {
        User = user;
        Number = number;
        Pnr = pnr;
    }
 }