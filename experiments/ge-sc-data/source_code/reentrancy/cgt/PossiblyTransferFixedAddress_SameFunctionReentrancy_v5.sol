pragma solidity ^0.5.17;

contract Reentrancy {
    mapping(address => bool) private userBalances;
    address payable private receiver = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);

    constructor() public payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        receiver.transfer(500000);
        userBalances[msg.sender] = true;
    }

}
