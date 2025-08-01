pragma solidity ^0.6.12;

contract Reentrancy {
    mapping(address => bool) private userBalances;

    constructor() public payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        msg.sender.transfer(500000);
        userBalances[msg.sender] = true;
    }

}
