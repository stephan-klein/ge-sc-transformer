pragma solidity ^0.8.0;

contract Reentrancy {
    mapping(address => bool) private userBalances;

    constructor() payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        payable(msg.sender).transfer(500000);
        userBalances[msg.sender] = true;
    }

}
