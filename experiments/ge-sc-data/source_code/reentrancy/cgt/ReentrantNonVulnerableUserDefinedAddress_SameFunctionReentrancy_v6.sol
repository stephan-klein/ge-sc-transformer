pragma solidity ^0.6.12;

contract Reentrancy {
    mapping(address => uint) public userRequests;

    constructor() public payable {}

    function request() public {
        userRequests[msg.sender] += 1;
        (bool success,) = msg.sender.call("");
        require(success);
    }

}
