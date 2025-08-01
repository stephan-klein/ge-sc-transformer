pragma solidity ^0.4.4;

contract MyContract {
    string s;
    address owner;
    
    modifier isOwner() {
        if (msg.sender != owner) throw;
        _;
    }
    
    event Update(string s);
    
    function MyContract() {
        owner = msg.sender;
    }

    function set(string _s) isOwner {
        s = _s;
        Update(_s);
    }
    
    function kill() isOwner {
        selfdestruct(owner);
    }
}