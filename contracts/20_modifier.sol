// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract FunctionModifier {

    address public owner;

    uint public a;

    uint public b;

    uint public c;

    constructor(){
        owner = msg.sender;
    }

    // 可以被继承
    modifier onlyOwner(){
        require(msg.sender == owner, "only owner");
        _;
    }

    function setA(uint data) external onlyOwner returns(uint){
        a = data;
        return a;
    }

    modifier onlyNotOwner(){
        require(msg.sender != owner, "only not owner");
        _;
    }

    function setB(uint data) external onlyNotOwner returns(uint){
        b = data;
        return b;
    }

    modifier onlyGtOne(uint data){
        if(data > 1){
            _;
        }
        revert("data is not gt 1");
    }

    function setC(uint data) external onlyGtOne(data) returns(uint){
        c = data;
        return c;
    }

    uint public d;

    // 不可重入 相当于java中的锁
    bool public locked;
    modifier noReentrancy(){
        require(locked == false,"reentrancy invoker");
        locked = true;
        _;
        locked = false;
    }

    function setD(uint data) external noReentrancy returns(uint){
        d = data;
    }
}