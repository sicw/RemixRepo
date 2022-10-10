// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    bytes和string也是数组, 但是string没有length和下标访问方法
    在calldata和memory中他俩使用紧密打包
    bytes比bytes1[] gas费用更低
    一个基本原则:
    任意长度的字节数据使用bytes
    任意长度的字符串数据使用string
    有长度限制的字节数组使用bytes1 ... bytes32

    数组的成员:
    length  数组的长度,string没有该方法
    push()  动态storage以及bytes有该方法, 添加新的0初始化的元素到末尾, 返回引用. x.push().t = 2
    push(x) 动态storage以及bytes有该方法, 添加一个元素, 没有返回值
    pop()   动态storage以及bytes有该方法, 从末尾删除元素, 也会在删除的元素中调用delete, 没有返回值.

    注意:
    避免悬空引用
*/
contract TypesArray {
    
    // 固定长度3的数组
    // public类型自动生成getter方法 uint x = a(index)
    uint[3] public a;

    // b是一个数组长度为2, 每个元素是uint[3]
    // 访问第二个uint[3]中的, 第三个元素 b[1][2]
    uint[3][2] b;

    // c是个动态数组
    // 使用push追加一个元素
    uint[] c;

    function addElement() external {
        c.push(1);
    }

    /*
        字符串拼接, 先将其他类型转成string 例如: string(bytes xxx)
        bytes拼接, 先将其他类型转换成bytes或bytesx 例如: bytes(string xxx)
    */
    string s = "Storage";
    function f(bytes calldata bc, string memory sm, bytes16 bo) public view {
        string memory concatString = string.concat(s, string(bc), "Literal", sm);
        assert((bytes(s).length + bc.length + 7 + bytes(sm).length) == bytes(concatString).length);

        bytes memory concatBytes = bytes.concat(bytes(s), bc, bc[:2], "Literal", bytes(sm), bo);
        assert((bytes(s).length + bc.length + 2 + 7 + bytes(sm).length + b.length) == concatBytes.length);
    }

    /*
        创建内存数组, 一经创建其大小就固定了(可以通过参数控制数组的大小)
    */
    function createMemoryArray(uint len) external pure {
        uint[] memory aa = new uint[](len);
        bytes memory bb = new bytes(len);

        assert(aa.length == len);
        assert(bb.length == len);

        aa[1] = 1;
        bb[1] = 0x01;
    }

    /*
        数组常量
        [1,2,3]代表的是 uint8[3] memory
        如果想用uint256[3]数组的开头元素类型要转换成uint256
    */
    function arrayConstant() external pure {
        // 说明定长数组不能赋值给变长数组
        // uint8[] memory x = [1,2,3];
        uint8[3] memory xx = [1,2,3];
        uint256[3] memory y = [uint256(1),2,3];

        assert(xx.length == 3);
        assert(y.length == 3);
    }

    /*
        数组切片目前只允许用在calldata中
        arr[start,end] 
        start <= 取值的范围 < end
    */
    function arraySlice(uint[] calldata arr) external pure {
        // calldata给memory赋值
        uint[] memory arr1 = arr[1:];
        assert(arr1.length <= arr.length);
    }
}