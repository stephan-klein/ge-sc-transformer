pragma solidity ^0.4.26;

contract Reentrancy {
    mapping(address => bool) private userBalances;

    function Reentrancy() payable {}

    function withdrawBalance() public {
        require(!userBalances[msg.sender]);
        bool success = msg.sender.send(500000);
        require(success);
        userBalances[msg.sender] = true;
    }

}
