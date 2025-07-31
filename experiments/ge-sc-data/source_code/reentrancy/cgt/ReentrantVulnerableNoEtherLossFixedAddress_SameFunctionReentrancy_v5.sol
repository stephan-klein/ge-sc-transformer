pragma solidity ^0.5.17;

contract Reentrancy {
    mapping(address => bool) public userCalled;
    address payable private receiver = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);
    uint public userRequests;
    address public winner;

    constructor() public payable {}

    function request() public {
        // the 100th address to call the contract wins
        require(userRequests < 100);
        require(!userCalled[msg.sender]);

        userRequests += 1;
        bool success = false;
        if (userRequests == 100) {
            (success,) = receiver.call(abi.encodeWithSignature("winner()"));
            require(success);
            winner = msg.sender;
        } else {
            (success,) = receiver.call(abi.encodeWithSignature("loser()"));
            require(success);
        }

        userCalled[msg.sender] = true;
    }

}
