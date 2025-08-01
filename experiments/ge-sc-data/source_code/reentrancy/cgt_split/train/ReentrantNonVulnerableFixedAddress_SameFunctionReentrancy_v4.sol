pragma solidity ^0.4.26;

contract Reentrancy {
    mapping(address => uint) public userRequests;
    address private receiver = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);

    function Reentrancy() payable {}

    function request() public {
        userRequests[msg.sender] += 1;
        bool success = receiver.call("");
        require(success);
    }

}
