// see https://github.com/uni-due-syssec/eth-reentrancy-attack-patterns/blob/master/delegated.sol
pragma solidity ^0.6.12;

// The Bank contract uses a dynamic library contract SafeSending, which
// handles parts of the business logic. In this case the SafeSending library is
// a minimalistic library that simply performs an external call.
//
// This obfuscates the unsafe use of CALL behind a DELEGATECALL instruction. In
// a more realistic scenario the library would implement something more
// sophisticated.

library SafeSending {
    function send(address to, uint256 amount) public {
        // external call, control goes back to attacker
        payable(to).send(amount);
    }
}

contract Bank {
    mapping(address => uint) public balances;
    address owner;
    address private receiver = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);
    address safesender;

    constructor(address _safesender) public payable  {
        owner = msg.sender;
        safesender = _safesender;
    }


    function getBalance(address who) public view returns (uint) {
        return balances[who];
    }

    function donate() payable public {
        balances[receiver] += msg.value;
    }

    function withdraw(uint amount) public {
        if (balances[receiver] >= amount) {
            // instead of using send, transfer or call here, transfer is passed
            // to the library contract, which handles sending Ether.
            _libsend(receiver, amount);
            // state update after the DELEGATECALL
            balances[receiver] -= amount;
        }
    }

    function _libsend(address to, uint256 amount) internal {
        // call send function of the Library contract with DELEGATECALL
        address(safesender).delegatecall(abi.encodeWithSignature("send(address,uint256)", to, amount));
    }
}
