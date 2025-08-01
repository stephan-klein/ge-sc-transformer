// based on https://github.com/uni-due-syssec/eth-reentrancy-attack-patterns/blob/master/create-based.sol (Sereum researchers)
pragma solidity ^0.8.0;

abstract contract IntermediaryCallback {
    function registerIntermediary(address what) public virtual payable;
}

contract Intermediary {
    address owner = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);
    Bank bank;

    constructor(Bank _bank) payable {
        bank = _bank;

        payable(owner).send(msg.value);
    }
	
}

contract Bank {
    mapping(address => uint) balances;
    mapping(address => Intermediary) subs;

    function getBalance(address a) public view returns (uint) {
        return balances[a];
    }

    function withdraw(uint amount) public {
        if (balances[msg.sender] >= amount) {
            // The new keyword creates a new contract (in this case of type
            // Intermediary). This is implemented on the EVM level with the CREATE
            // instruction. CREATE immediately runs the constructor of the
            // contract. i.e this must be seen as an external call to another
            // contract.
            // Even though the contract can be considered "trusted", it can
            // perform further problematic actions (e.g. more external calls)
            subs[msg.sender] = new Intermediary{value: amount}(this);
            // state update **after** the CREATE
            balances[msg.sender] -= amount;
        }
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
}
