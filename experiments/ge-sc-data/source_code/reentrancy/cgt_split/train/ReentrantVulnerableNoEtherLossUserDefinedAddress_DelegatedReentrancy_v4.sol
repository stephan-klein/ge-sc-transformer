pragma solidity ^0.4.26;

library SafeSending {
    function send(address to) public {
        // external call, control goes back to attacker
        to.call("");
    }
}

contract Reentrancy {
    uint public userRequests;
    SafeSending safesender;

    function Reentrancy(SafeSending _safesender) payable {
        safesender = _safesender;
    }

    function request() public {
        _libsend(msg.sender);
        userRequests += 1;
    }

    function _libsend(address to) internal {
        // call send function of the Library contract with DELEGATECALL
        address(safesender).delegatecall(abi.encodeWithSignature("send(address)", to));
    }

}
