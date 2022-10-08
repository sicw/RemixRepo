// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    外部与合约调用, 合约与合约调用, 都是通过abi协议来实现的.
    abi中主要描述如何调用一个合约中的方法, 主要分为几大类
    1. 函数选择器
    2. 参数编码
    3. 类型编码
*/
contract AbiContract{

    event Log(string);

    // 数据格式 4字节函数选择其器 + 编码的参数
    // |函数选择器| + |参数编码|

    // ------- 函数选择器 -------- //
    // 在一个函数调用的数据中, 前四个字节指定了要调用那个函数. 它就是函数签名的keccak哈希的前四个字节(高位在左的大端序)
    // 函数签名: 函数名(参数类型1,参数类型2,参数类型3) 注意参数类型中间没有空格 如下:
    // bytes4(keccak('baz(uint32,bool)'))

    // ------- 参数编码 --------- //
    /*
        参数分为 静态和动态
        静态类型:
            动态类型剩下的都是静态类型, 会进行直接编码
            [头部]
            uint32 a = 123;
            编码成:
            0x000000...00007b

        动态类型:
            bytes
            string
            T[]     // 任意类型的变长数组
            T[k]    // 动态类型的定长数组
            Ti(T1, T2... Tk)    // 由动态类型T组成的元组

            动态类型会在当前位置设置偏移量 偏移量所在位置是实际的数据存储
            [头部][数据部分]
    */

    /*
        非标准打包模式 (Non-standard Packed Mode)

        000000000000000000000000000000000000000000000000000000000000007b    0 - 1F
        0000000000000000000000000000000000000000000000000000000000000080    20 - 3F
        0000000000000000000000000000000000000000000000000000000000000001    40 - 5F
        0000000000000000000000000000000000000000000000000000000000000002    60 - 7F
        0000000000000000000000000000000000000000000000000000000000000003    80 - 9F
        6162630000000000000000000000000000000000000000000000000000000000    A0 - BF

        注意:
        encode非紧密编码, 不论uint24、uint16在编码后和解码后都是使用uint256存储
    */
    function encodeParams() external pure returns (bytes memory) {
        // 0 - 1F 编码的是 num = 123
        uint24 num = 123;
        // 20 - 3F 编码的是 str = "abc"
        // 1). 0x0000...80 代表从偏移量0x80开始
        // 2). 0x80中存储的0x03代表的是接下来的长度
        // 3). 616263存储的abc实际的参数
        string memory str = "abc";
        // 40 - 5F  存储的是 arr[0]
        // 60 - 7F  存储的是 arr[1]
        uint16[2] memory arr = [uint16(1), uint16(2)];
        return abi.encode(num, str, arr);
    }

    /*
        严格打包模式, 按照类型编码参数
        00007b
        616263
        0000000000000000000000000000000000000000000000000000000000000001
        0000000000000000000000000000000000000000000000000000000000000002
        01
        如下: 两个参数都是动态类型, 很容易混淆, 所以没有特殊原因优先使用abi.encode
        abi.encodePacked("a", "bc") == abi.encodePacked("ab", "c")
    */
    function encodePackedParams() external pure returns (bytes memory) {
        uint24 num = 123;
        string memory str = "abc";
        // 数组内的uint还是32byte的
        uint16[2] memory arr = [uint16(1), uint16(2)];
        bool bl = true;
        return abi.encodePacked(num, str, arr, bl);
    }

    /*
        解码参数
    */
    function decodeParams(bytes memory data) external pure returns(uint32, string memory, uint32[2] memory) {
        return abi.decode(data,(uint32, string, uint32[2]));
    }

    /*
        编码函数签名

        参数:
        "foo(uint32,string,uint32[2])"
        返回值:
        0xc937354e
    */
    function encodeFunctionSignature(string memory funcSignature) external pure returns(bytes4){
        return bytes4(keccak256(bytes(funcSignature)));
    }

    /*
        使用函数选择器 + 参数进行编码
        相当于是 selector + enc(num,str,arr)

        参数:
        "foo(uint32,string,uint32[2])",1,"abc",[1,2]
        返回值:
        0xc937354e
        0000000000000000000000000000000000000000000000000000000000000001
        0000000000000000000000000000000000000000000000000000000000000080
        0000000000000000000000000000000000000000000000000000000000000001
        0000000000000000000000000000000000000000000000000000000000000002
        0000000000000000000000000000000000000000000000000000000000000003
        6162630000000000000000000000000000000000000000000000000000000000
    */
    function encodeWithSelector(string memory funcSignature, uint32 num, string memory str, uint32[2] memory arr) external pure returns(bytes memory){
        bytes4 selector = bytes4(keccak256(bytes(funcSignature)));
        return abi.encodeWithSelector(selector, num, str, arr);
    }

    /*
        使用函数pointer, 更方便
    */
    function encodeWithFunctionPointer(uint32 num, string memory str, uint32[2] memory arr) external pure returns(bytes memory){
        return abi.encodeWithSelector(AbiContract.foo.selector,num,str,arr);
    }

    /*
        相当于encodeWithSelector
    */
    function encodeWithSignature(string memory funcSignature, uint32 num, string memory str, uint32[2] memory arr) external pure returns(bytes memory){
        return abi.encodeWithSignature(funcSignature, num, str, arr);
    }

    /*
        效果和encodeWithFunctionPointer一样
        但是它可以进行类型检查, 不匹配时编译就报错
        0.8.12之后版本加的
    */
    function encodeCall(uint32 num, string memory str, uint32[2] memory arr) external pure returns(bytes memory){
        return abi.encodeCall(AbiContract.foo, (num, str, arr));
    }

    // 签名: foo(uint32,string,uint32[2])
    function foo(uint32 num, string memory str, uint32[2] memory arr) external returns (uint32, string memory, uint32[2] memory) {
        emit Log("foo");
        return (num+1, str, arr);
    }

    fallback() external {
        emit Log("fall back");
    }
}