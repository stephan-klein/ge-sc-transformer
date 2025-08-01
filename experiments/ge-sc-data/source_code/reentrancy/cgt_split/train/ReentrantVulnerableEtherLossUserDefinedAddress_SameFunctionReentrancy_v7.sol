pragma solidity ^0.7.6;

contract Reentrancy {
    mapping(address => bool) private userBalances;

    constructor() payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        (bool success,) = msg.sender.call{value: 500000}("");
        require(success);
        userBalances[msg.sender] = true;
    }

}
