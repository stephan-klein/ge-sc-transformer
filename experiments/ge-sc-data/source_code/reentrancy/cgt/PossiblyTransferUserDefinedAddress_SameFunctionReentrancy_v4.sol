pragma solidity ^0.4.26;

contract Reentrancy {
    mapping(address => bool) private userBalances;

    function Reentrancy() payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        msg.sender.transfer(500000);
        userBalances[msg.sender] = true;
    }

}
