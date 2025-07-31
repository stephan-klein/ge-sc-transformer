pragma solidity ^0.6.12;

contract Reentrancy {
    mapping(address => bool) private userBalances;
    bool public lock = false;

    constructor() public payable {}

    modifier nonReentrant() {
        require(lock == false);
        lock = true;
        _;
        lock = false;
    }

    function withdrawBalance() public nonReentrant {
        require(!userBalances[msg.sender]);
        (bool success,) = msg.sender.call{value: 500000}("");
        require(success);
        userBalances[msg.sender] = true;
    }

}
