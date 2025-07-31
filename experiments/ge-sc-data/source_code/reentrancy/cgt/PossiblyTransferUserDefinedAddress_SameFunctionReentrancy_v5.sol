pragma solidity ^0.5.17;

contract Reentrancy {
    mapping(address => bool) private userBalances;

    constructor() public payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        msg.sender.transfer(500000);
        userBalances[msg.sender] = true;
    }

}
