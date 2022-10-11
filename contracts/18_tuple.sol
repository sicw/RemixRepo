// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    解构赋值
    (uint a, bool b, string c,) = f()

    返回值
    function f() external returns (uint, bool, string memory){
        return (1,true,'abc');
    }
*/
contract TupleContract{

    function a() external pure returns(uint){
        // 接收tuple, 不需要的可以使用,代替  不能没有
        (uint num,,) = b();
        return num;
    }

    // 返回值是tuple
    function b() internal pure returns(uint, bool, string memory){
        // 返回tuple
        return (123, true, 'abc');
    }
}