pragma solidity ^0.4.26;

contract Reentrancy {
    mapping(address => bool) public userCalled;
    address private receiver = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);
    uint public userRequests;
    address public winner;

    function Reentrancy() payable {}

    function request() public {
        // the 100th address to call the contract wins
        require(userRequests < 100);
        require(!userCalled[msg.sender]);

        userRequests += 1;
        bool success = false;
        if (userRequests == 100) {
            success = receiver.call(abi.encodeWithSignature("winner()"));
            require(success);
            winner = msg.sender;
        } else {
            success = receiver.call(abi.encodeWithSignature("loser()"));
            require(success);
        }

        userCalled[msg.sender] = true;
    }

}
