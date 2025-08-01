pragma solidity ^0.6.12;

contract Reentrancy {
    mapping(address => bool) public userCalled;
    uint public userRequests;
    address public winner;
    address payable private receiver = payable(address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef));

    constructor() public payable {}

    function request() public {
        // the 100th address to call the contract wins
        require(userRequests < 100);
        require(!userCalled[msg.sender]);

        userRequests += 1;
        if (userRequests == 100) {
            (bool success,) = receiver.call(abi.encodeWithSignature("winner()"));
            require(success);
            winner = msg.sender;
        } else {
            (bool success,) = receiver.call(abi.encodeWithSignature("loser()"));
            require(success);
        }

        userCalled[msg.sender] = true;
    }

}
