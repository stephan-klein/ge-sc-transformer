pragma solidity ^0.6.12;

library SafeSending {
    function send(address to) public {
        // external call, control goes back to attacker
        to.call("");
    }
}

contract Reentrancy {
    uint public userRequests;
    address payable private receiver = payable(address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef));
    address safesender;

    constructor(address _safesender) public payable {
        safesender = _safesender;
    }

    function request() public {
        userRequests += 1;
        _libsend(receiver);
    }

    function _libsend(address to) internal {
        // call send function of the Library contract with DELEGATECALL
        address(safesender).delegatecall(abi.encodeWithSignature("send(address)", to));
    }

}
