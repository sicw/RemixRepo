// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

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