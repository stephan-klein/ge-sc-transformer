pragma solidity ^0.7.6;

contract Reentrancy {
    mapping(address => uint) public userRequests;

    constructor() payable {}

    function request() public {
        userRequests[msg.sender] += 1;
        (bool success,) = msg.sender.call("");
        require(success);
    }

}
