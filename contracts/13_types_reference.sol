// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract ReferenceContract {

    /*
        引用类型:
        数组、结构体、映射 如果使用引用类型需要指明他的存储类型(memory calldata storage)
    
        数据位置:
        memory: 存储在内存中, 生命周期就是函数调用期间
        storage: 状态变量保存的位置, 只要合约在就一直保存.
        calldata: 函数参数的特殊位置数据, 不可修改(只读), 也不会复制数据
    
        不同的数据位置也有不同的赋值行为
        storage 和 memory(calldata)相互赋值会产生一份完整的拷贝. storage a = memory b 修改b 不会影响到a的值
        memory 到 memory的赋值只创建引用, b = a; 意味着修改a引用的数据, b引用的数据也会更改
        storage 到 local storage的赋值也是引用赋值 int[] storage a = storage b;
        其他对storage的赋值, 总是进行一份拷贝.
    */

    // x 的数据存储位置是storage(默认的)
    uint[] x; 

    // memoryArray 的数据存储位置是 memory
    function f(uint[] memory memoryArray, uint[] calldata calldataArray) public {
        // 将整个数组拷贝到 storage 中
        x = memoryArray;
        x = calldataArray;

        // y local storage
        // 分配一个指向x的引用
        uint[] storage y = x;

        // 访问y或x的第8个元素
        y[7];

        // 通过 y 修改 x
        y.pop();

        // 清除数组，同时修改 y
        delete x;

        // 下面两种情况是不允许的, 不允许对引用的赋值做处理 
        // y = memoryArray;
        // delete y;

        // 对原始的引用数据可以操作
        x = memoryArray;
        delete x;

        // calldata特殊存储位置, 不允许修改
        // calldataArray = [1,2,3];

        // 调用g函数, 同时传递引用
        g(x); 
        // 调用h函数, 同时在memory中创建一个完整的拷贝
        h(x); 
    }

    function g(uint[] storage ) internal pure {}
    function h(uint[] memory) public pure {}
}