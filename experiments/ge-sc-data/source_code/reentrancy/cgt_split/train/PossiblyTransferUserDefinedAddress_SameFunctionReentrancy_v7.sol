pragma solidity ^0.7.6;

contract Reentrancy {
    mapping(address => bool) private userBalances;

    constructor() payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        msg.sender.transfer(500000);
        userBalances[msg.sender] = true;
    }

}
