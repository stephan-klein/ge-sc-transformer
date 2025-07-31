pragma solidity ^0.5.17;

contract Reentrancy {
    mapping(address => uint256) tokenBalance;
    mapping(address => uint256) etherBalance;
    address payable private receiver = address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef);

    constructor() public payable {}

    function withdrawAll() public {
        uint256 etherAmount = etherBalance[msg.sender];
        uint256 tokenAmount = tokenBalance[msg.sender];
        require(etherAmount > 0 && tokenAmount > 0);
        uint256 e = etherAmount + (tokenAmount * 2);
        etherBalance[msg.sender] = 0;
        tokenBalance[msg.sender] = 0;
        receiver.call.value(e)("");
    }

    function updateBalance() public payable {
        etherBalance[msg.sender] += msg.value;
    }
}
