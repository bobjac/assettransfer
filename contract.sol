pragma solidity ^0.4.10;

contract Bag {
    string Number;
    string Pnr;
    address User;
 
    enum AssetState { Complete }
 
    AssetState State;
 
    function Bag() public {}

    function upload(address user, string number, string pnr) public {
        User = user;
        Number = number;
        Pnr = pnr;
    }
}