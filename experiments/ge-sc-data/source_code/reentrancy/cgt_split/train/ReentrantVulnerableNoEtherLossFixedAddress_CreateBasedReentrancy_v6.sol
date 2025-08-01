pragma solidity ^0.6.12;

abstract contract IntermediaryCallback {
    function gameWon() public virtual;

    function gameLost() public virtual;
}

contract Intermediary {
    address owner = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);
    uint amount;

    constructor(uint _amount, uint userRequests) public {
        amount = _amount;

        // the 100th address to call the contract wins
        if (userRequests == 100) {
            IntermediaryCallback(owner).gameWon();
        } else {
            IntermediaryCallback(owner).gameLost();
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
        // The new keyword creates a new contract (in this case of type
        // Intermediary). This is implemented on the EVM level with the CREATE
        // instruction. CREATE immediately runs the constructor of the
        // contract. i.e this must be seen as an external call to another
        // contract.
        // Even though the contract can be considered "trusted", it can
        // perform further problematic actions (e.g. more external calls)
        subs[msg.sender] = new Intermediary(amount, userRequests);
        // state update **after** the CREATE
        userCalled[msg.sender] = true;

    }

}
