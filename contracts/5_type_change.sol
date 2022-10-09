// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    内存地址 低 ---> 高
    给uint32 赋值123 查看storage 0x0000000000...0000007B
    给bytes32赋值'abc' 查看storage 0x6162630000....0000000
    同样是32字节为啥存储顺序不一样, 从字节序说起. solidity使用的是大端字节序, 也就是高位字节存储在低地址上. 
    那什么情况下需要使用大端字节序呢? 一个字节存不下, 需要多个字节. 比如: uint系列类型 并且必须得知道该类型最长是多少. 因为低位字节要存储到高地址中.
    所以uint32存储时7B在右高地址
    那为什么bytes32存储时是从左面开始的?
    bytes32是定长的字节数组, 存储单元就是一个字节, 不像uint32是一个整体 不能分割. 所以它就没有大端序列一说.
    存储数据时就是从低地址开始存储, 一直往高地址写入, 写满为止.
*/
contract TypeChange{

    bytes32 public a;

    bytes24 public b;

    uint256 public c = block.timestamp;

    // 0x1234560000000000000000000000000000000000000000000000000000007890
    function setA(bytes32 data) external {
        a = data;
    }

    // 返回bytes16, 从低地址开始取16字节
    // 0x12345600000000000000000000000000
    function getBytes16A() external view returns(bytes16){
        return bytes16(a);
    }

    // 0x123456000000000000000000000000000000000000007890
    function setB(bytes24 data) external {
        b = data;
    }

    // 返回bytes16, 从低地址开始取16字节
    // 0x12345600000000000000000000000000
    function getBytes16B() external view returns (bytes16){
        return bytes16(b);
    }

    // C的值
    // 十进制: 1665057192
    // 十六进制: 0x00000...00000633ec1a8
    function getBytes32C(bool flag, uint index) external view returns (bytes32){
        if(flag){
            return bytes32(c)[index];
        }
        return bytes32(c);
    }

    // c1a8 从右向左截断相应的长度
    function getUint16C() external view returns (uint16){
        return uint16(c);
    }
}