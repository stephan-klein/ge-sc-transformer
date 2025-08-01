pragma solidity ^0.4.26;

contract Reentrancy {
    mapping(address => bool) private userBalances;
    address private receiver = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);

    function Reentrancy() payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        receiver.transfer(500000);
        userBalances[msg.sender] = true;
    }

}
