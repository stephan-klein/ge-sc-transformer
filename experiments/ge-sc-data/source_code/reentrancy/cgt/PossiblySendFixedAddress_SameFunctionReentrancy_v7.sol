pragma solidity ^0.7.6;

contract Reentrancy {
    mapping(address => bool) private userBalances;
    address payable private receiver = payable(address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef));

    constructor() payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        bool success = receiver.send(500000);
        require(success);
        userBalances[msg.sender] = true;
    }

}
