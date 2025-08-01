// based on https://github.com/uni-due-syssec/eth-reentrancy-attack-patterns/blob/master/create-based.sol (Sereum researchers)
pragma solidity ^0.7.6;

abstract contract IntermediaryCallback {
    function registerIntermediary(address what) public virtual payable;
}

contract Intermediary {
    // this contract just holds the funds until the owner comes along and
    // withdraws them.

    address owner = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);
    Bank bank;

    constructor(Bank _bank) {
        bank = _bank;

        // this contract wants to register itself with its new owner, so it
        // calls the new owner (i.e. the attacker). This passes control to an
        // untrusted third-party contract.
        IntermediaryCallback(owner).registerIntermediary(address(this));
    }

}

contract Bank {
    mapping(address => uint) counter;
    mapping(address => Intermediary) subs;

    function getCounter(address a) public view returns (uint) {
        return counter[a];
    }

    function count() public {
        counter[msg.sender] += 1;
        subs[msg.sender] = new Intermediary(this);
    }
}
