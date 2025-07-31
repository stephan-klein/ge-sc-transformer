pragma solidity ^0.7.6;

contract Reentrancy {
    mapping(address => bool) private userBalances;
    address payable private receiver = payable(address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef));

    constructor() payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        receiver.transfer(500000);
        userBalances[msg.sender] = true;
    }

}
