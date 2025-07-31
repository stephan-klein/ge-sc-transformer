pragma solidity ^0.5.17;

contract Reentrancy {
    mapping(address => bool) private userBalances;
    address payable private receiver = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);

    constructor() public payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        (bool success,) = receiver.call.value(500000)("");
        require(success);
        userBalances[msg.sender] = true;
    }

}
