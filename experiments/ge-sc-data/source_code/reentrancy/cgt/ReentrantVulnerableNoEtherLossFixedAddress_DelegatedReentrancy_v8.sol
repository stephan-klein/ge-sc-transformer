pragma solidity ^0.8.0;

library SafeSending {
    function send(address to) public {
        // external call, control goes back to attacker
        to.call("");
    }
}

contract Reentrancy {
    uint public userRequests;
    address private receiver = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);
    address safesender;

    constructor(address _safesender) payable {
        safesender = _safesender;
    }

    function request() public {
        _libsend(receiver);
        userRequests += 1;
    }

    struct s {bytes4 sig; address to;}

    function _libsend(address to) internal {
        // call send function of the Library contract with DELEGATECALL
        address(safesender).delegatecall(abi.encodeWithSignature("send(address)", to));
    }

}
