// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract SelfDestruct {

    event Log(address sender, uint value);

    function destruct(address payable _destAddr) external {
        require(_destAddr != address(0), "dest address is null");
        // 销毁自己, 将余额发送给_destAddr合约
        // _destAddr在接收到eth时, 不执行receive / fallback方法
        selfdestruct(_destAddr);
    }

    receive() external payable{
        emit Log(msg.sender, msg.value);
    }

}