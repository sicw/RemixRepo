// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract D {

    // 状态变量可见性 public internal(默认的) private
    uint public x;

    event Log(address send, uint value);

    constructor() payable {

    }

    /*
        只有外部函数调用才会产生evm调用, 内部则不会
        函数可见性
        public external internal private
    */
    function setX(uint data) external {
        x = data;
    }

    receive() external payable{
        emit Log(msg.sender, msg.value);
    }
}

/*
    modifier
    constant 和 Immutable
    状态可变性 怎么算修改状态了
    receive和fallback
    override
    event
    error
    is
    abstract
    interface
    library
*/
contract ContarctDemo {
    
    event Log(address addr, uint x);

    constructor() payable {

    }

    // 创建合约
    function createContract() external {
        // 构造函数是payable 可以在构建时支付一定的eth
        D d = new D{value:1}();
        d.setX(123);
        emit Log(address(d), d.x());
    }

    // 销毁自己, 发送余额给addr
    function destorySelf(address payable addr) external {
        selfdestruct(addr);
    }

}