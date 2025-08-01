pragma solidity ^0.8.0;

contract Reentrancy {
    mapping(address => bool) private userBalances;

    constructor() payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        bool success = payable(msg.sender).send(500000);
        require(success);
        userBalances[msg.sender] = true;
    }

}
