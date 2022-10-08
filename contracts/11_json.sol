// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    合约的json格式用来描述函数, 事件, 错误的一个数组. 有如下字段:
    type: function(缺省默认) constructor fallback event error
    name: 函数名, 事件名等
    inputs: 参数
        name: 参数名称
        type: 参数类型
        components: 元组类型使用
    outputs: 返回值
        name
        type
        components
    payable: true or false函数是否接收以太币
    stateMutability: pure(不读取状态变量) view(不修改状态变量) nonpayable(不接收以太币 默认值) payable(接收以太币)
    anonymous: 事件描述是否匿名
*/
contract JsonContract{

    event Event(uint indexed a, bytes32 b);
    event Event2(uint indexed a, bytes32 b);
    error InsufficientBalance(uint256 available, uint256 required);

    // 声明为public时abi中多了如下描述, 所以可以函数调用public修饰的变量
    /*
        {
            "inputs": [],
            "name": "b",
            "outputs": [
                {
                    "internalType": "bytes32",
                    "name": "",
                    "type": "bytes32"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        }
    */
    bytes32 public b;

    constructor () { 
        b = "abc"; 
    }

    function foo(uint a) public { 
        emit Event(a, b); 
    }

    /*
    [
        {
            "inputs":[

            ],
            "stateMutability":"nonpayable",
            "type":"constructor"
        },
        {
            "inputs":[
                {
                    "internalType":"uint256",
                    "name":"available",
                    "type":"uint256"
                },
                {
                    "internalType":"uint256",
                    "name":"required",
                    "type":"uint256"
                }
            ],
            "name":"InsufficientBalance",
            "type":"error"
        },
        {
            "anonymous":false,
            "inputs":[
                {
                    "indexed":true,
                    "internalType":"uint256",
                    "name":"a",
                    "type":"uint256"
                },
                {
                    "indexed":false,
                    "internalType":"bytes32",
                    "name":"b",
                    "type":"bytes32"
                }
            ],
            "name":"Event",
            "type":"event"
        },
        {
            "anonymous":false,
            "inputs":[
                {
                    "indexed":true,
                    "internalType":"uint256",
                    "name":"a",
                    "type":"uint256"
                },
                {
                    "indexed":false,
                    "internalType":"bytes32",
                    "name":"b",
                    "type":"bytes32"
                }
            ],
            "name":"Event2",
            "type":"event"
        },
        {
            "inputs": [],
            "name": "b",
            "outputs": [
                {
                    "internalType": "bytes32",
                    "name": "",
                    "type": "bytes32"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs":[
                {
                    "internalType":"uint256",
                    "name":"a",
                    "type":"uint256"
                }
            ],
            "name":"foo",
            "outputs":[

            ],
            "stateMutability":"nonpayable",
            "type":"function"
        }
    ]
    */

}