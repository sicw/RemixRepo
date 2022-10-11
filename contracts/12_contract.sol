// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract D {
    uint public x;

    event Log(address send, uint value);

    constructor() payable {

    }

    function setX(uint data) external {
        x = data;
    }

    receive() external payable{
        emit Log(msg.sender, msg.value);
    }
}

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