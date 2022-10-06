// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    bytes1 byte2 ... bytes31 bytes32都是定长数组类型
    bytes1 bytes2 ...... bytes32
    1. 比较运算符 <= < == != >= > 返回布尔值
    2. 位运算符 & | ^ ~(非)
    3. 位移运算符 <<(左移) >>(右移)
    4. 索引访问 x[i] 返回第i的字节的值
*/
contract FixedByteArray{

    // 定长字节数组
    bytes32 public a;
    bytes32 public b;
    bytes3 public c;
    uint public d;
    // slot4 0x905556781234
    uint16 public e;    // 0x1234
    uint16 public f;    // 0x5678
    uint16 public g;    // 0x9055

    function setA(bytes32 data) external {
        a = data;
    }

    function setB(bytes32 data) external {
        b = data;
    }

    function setC(bytes3 data) external {
        c = data;
    }

    function setD(uint data) external {
        d = data;
    }

    function setE(uint16 data) external {
        e = data;
    }

    function setF(uint16 data) external {
        f = data;
    }

    function setG(uint16 data) external {
        g = data;
    }

    // 类型不同, 数值相同. 最终也不相等
    // 字节数组比较, 肯定是每个字节都要比较.
    // 伪代码类似如下:
    /*
        从index = 0开始比较
        while(aIdx < a.length && bInx < a.length){
            1. 比较aIdx和bIdx对应的字节大小
            2. 出现不同的返回 return
        }
        // aIdx != bIdx 说明长度不同, 返回false
    */
    function compare() external view returns (bool){
        // bytes7  a = 0x00000000000001
        // bytes32 b = 0x0000000000000000000000000000000000000000000000000000000000000001
        // return false
        return a == b;
    }

    function gt() external view returns(bool){
        // 类型不同 判断有问题
        // 一直为true
        return a > b;
    }

    function andB() external {
        b = a & b;
    }

    function reverseB() external {
        b = ~b;
    }

    // 不论是左移还是右移, 缺位补0
    function shiftLeftB(uint bitCount) external {
        // 进行位移时, 只能使用无符号类型
        b = b << bitCount;
    }

    function rightLeftB(uint bitCount) external {
        b = b >> bitCount;
    }

    // c = 0x1234567890
    // solidity采用大端存储模式, 低地址存储高位字节 正好书写按照顺序存储的
    /*
        低地址            ---->             高地址
        0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07

        0x1234567890存储排列方式:
        高位字节          ---->             低位字节
        0x12 0x34 0x56 0x78 0x90 0x00 0x00 0x00
        所以:
        c[0] = 0x12 c[1] = 0x34 c[2] = 0x56
    */
    function getCIdx(uint index) external view returns(bytes1){
        return c[index];
    }

    function getAIdx(uint index) external view returns(bytes1){
        return a[index];
    }

    // web3.utils.hexToNumberString('0x1234560000000000000000000000000000000000000000000000000000007890')
    // setD 十进制: 8234100872053094964343885742466156107944985754811990998090428875106854926480
    function getD() external view returns(bytes32){
        return bytes32(d);
    }

    // getDIdx(0) 0x12
    // getDIdx(1) 0x34
    // getDIdx(30) 0x78
    // getDIdx(31) 0x90
    function getDIdx(uint index) external view returns(bytes1){
        return bytes32(d)[index];
    }

    function getBLength() external view returns(uint) {
        return b.length;
    }
}