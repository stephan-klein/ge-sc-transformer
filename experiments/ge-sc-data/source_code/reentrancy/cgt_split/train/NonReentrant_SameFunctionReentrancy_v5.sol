pragma solidity ^0.5.17;

contract Reentrancy {
    mapping(address => bool) public userCalled;
    uint public userRequests;
    address public winner;

    constructor() public payable {}

    function request() public {
        // the 100th address to call the contract wins
        require(userRequests < 100);
        require(!userCalled[msg.sender]);

        userRequests += 1;
        if (userRequests == 100) {
            winner = msg.sender;
        }

        userCalled[msg.sender] = true;
    }

}
