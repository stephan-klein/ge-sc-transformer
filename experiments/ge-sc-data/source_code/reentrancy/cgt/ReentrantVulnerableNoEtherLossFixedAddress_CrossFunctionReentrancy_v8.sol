pragma solidity ^0.8.0;

contract Reentrancy {
    mapping(address => uint256) tokenBalance;
    mapping(address => uint256) etherBalance;
    address payable private receiver = payable(address(0xBEeFbeefbEefbeEFbeEfbEEfBEeFbeEfBeEfBeef));

    constructor() payable {}

    function withdrawAll() public {
        uint256 etherAmount = etherBalance[msg.sender];
        uint256 tokenAmount = tokenBalance[msg.sender];
        if (etherAmount > 0 && tokenAmount > 0) {
            uint256 e = etherAmount + (tokenAmount * 2);
            etherBalance[msg.sender] = 0;
            // cannot re-enter withdrawAll()
            // However, can re-enter transfer()
            receiver.call{value: e}("");
            // state update causing inconsistent state
            tokenBalance[msg.sender] = 0;
        }
    }

    function transfer(address to, uint256 amount) public {
        // uses inconsistent tokenBalance (>0) when re-entered
        if (tokenBalance[msg.sender] >= amount) {
            tokenBalance[to] += amount;
            tokenBalance[msg.sender] -= amount;
        }
    }
}
