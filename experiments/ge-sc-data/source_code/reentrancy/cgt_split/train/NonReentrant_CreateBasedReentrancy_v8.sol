pragma solidity ^0.8.0;


contract Intermediary {
    uint amount;
    address winner;

    constructor(uint _amount, address sender, uint userRequests) {
        amount = _amount;

        // the 100th address to call the contract wins
        if (userRequests == 100) {
            winner = sender;
        }

    }

}

contract Bank {
    mapping(address => Intermediary) subs;
    mapping(address => bool) public userCalled;
    uint public userRequests;


    function withdraw(uint amount) public {
        require(userRequests < 100);
        require(!userCalled[msg.sender]);

        userRequests += 1;
        userCalled[msg.sender] = true;
        subs[msg.sender] = new Intermediary(amount, msg.sender, userRequests);
    }

}
