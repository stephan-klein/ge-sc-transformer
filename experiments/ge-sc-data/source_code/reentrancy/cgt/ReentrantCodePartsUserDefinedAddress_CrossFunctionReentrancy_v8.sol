pragma solidity ^0.8.0;

contract Reentrancy {
    mapping(address => uint256) tokenBalance;
    mapping(address => uint256) etherBalance;
    bool public lock = false;

    constructor() payable {}

    modifier nonReentrant() {
        require(lock == false);
        lock = true;
        _;
        lock = false;
    }

    function withdrawAll() public nonReentrant {
        uint256 etherAmount = etherBalance[msg.sender];
        uint256 tokenAmount = tokenBalance[msg.sender];
        if (etherAmount > 0 && tokenAmount > 0) {
            uint256 e = etherAmount + (tokenAmount * 2);
            msg.sender.call{value: e}("");
            // state update causing inconsistent state
            etherBalance[msg.sender] = 0;
            tokenBalance[msg.sender] = 0;
        }
    }

    function transfer(address to, uint256 amount) public nonReentrant {
        // uses inconsistent tokenBalance (>0) when re-entered
        if (tokenBalance[msg.sender] >= amount) {
            tokenBalance[to] += amount;
            tokenBalance[msg.sender] -= amount;
        }
    }
}
