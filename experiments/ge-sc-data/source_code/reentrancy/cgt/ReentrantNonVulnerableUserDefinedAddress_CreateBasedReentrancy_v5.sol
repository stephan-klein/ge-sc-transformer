// based on https://github.com/uni-due-syssec/eth-reentrancy-attack-patterns/blob/master/create-based.sol (Sereum researchers)
pragma solidity ^0.5.17;

contract IntermediaryCallback {
    function registerIntermediary(address what) public payable;
}

contract Intermediary {

    Bank bank;
    address owner;

    constructor(Bank _bank, address _owner) public {
        bank = _bank;
        owner = _owner;

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
        subs[msg.sender] = new Intermediary(this, msg.sender);
    }
}
