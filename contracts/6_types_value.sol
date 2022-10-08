// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    Solidity是静态语言, 每个变量在编译时需要指定变量类型. null undefined在Solidity中是不存在的.
    具体的默认值和类型有关.

    值类型 在赋值和传递时总是进行值拷贝
*/
contract TypesValue{
    /*
        布尔类型 bool (true or false) 默认false
        运算符:
        ! 取非
        && 与逻辑 (遵循短路原则)
        || 或逻辑 (遵循短路原则)
        == 等于
        != 不等于
    */
    bool public a = true;

    /*
        整形
        int8/uint8 int16/uint16 ...... int256/uint256
        运算符:
        比较: < <= > >= != ==
        位运算: & | ~ ^
        移位: >> << (不会进行溢出检查 总是会截断补0)
        算数: + - * / % ** (-负数) (0.8版本之前的需要用SafeMath库防止溢出)
    */
    uint48 public b = 223344;

    // 计算该类型的最大值和最小值
    uint public bMax = type(uint48).max;
    uint public bMin = type(uint48).min;

    // 0.8版本后 算术运算符有两个模式 checked 和 unchecked的 默认是checked 会进行溢出检查.
    // 可以使用unchecked{} 恢复到之前不校验的模式 会有溢出问题
    uint8 public bAdd = 255;
    // 调用会报错, revert
    function addOneB() external {
        bAdd = bAdd + 1;
    }
    // bAdd = 0
    function addOneBUnchecked() external {
        unchecked{
            bAdd = bAdd + 1;
        }
    }
    uint8 public bSub = 0;
    // 调用会报错, revert
    function subOneB() external {
        bSub = bSub - 1;
    }
    // bSub = 255
    function subOneBUnchecked() external {
        unchecked{
            bSub = bSub - 1;
        }
    }
}