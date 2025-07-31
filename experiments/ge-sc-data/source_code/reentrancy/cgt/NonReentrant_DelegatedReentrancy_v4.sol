pragma solidity ^0.4.26;

library Calculator {
    function calc(uint16 a, uint16 b) public returns (uint) {
        return a + b;
    }
}

contract CalculatorUser {
    Calculator calculator;

    function CalculatorUser(Calculator _calculator) public {
        calculator = _calculator;
    }

    function calc(uint16 a) public {
        _libcalc(a);
    }

    function _libcalc(uint16 a) internal {
        address(calculator).delegatecall(abi.encodeWithSignature("calc(uint16,uint16)", a, 42));
    }
}
