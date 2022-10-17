// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract D {

    // 状态变量可见性 public internal(默认的) private
    uint public x;

    event Log(address send, uint value);

    constructor() payable {

    }

    /*
        只有外部函数调用才会产生evm调用, 内部则不会
        函数可见性
        public external internal private
    */
    function setX(uint data) external {
        x = data;
    }

    receive() external payable{
        emit Log(msg.sender, msg.value);
    }
}

/*
    constant    不可修改 支持字符串和值类型
    Immutable   不可修改 值类型

    状态可变性 怎么算修改状态了
    receive和fallback
    override
    event
    error
    is
    abstract
    interface
    library
*/
contract ContarctDemo {
    
    event Log(address addr, uint x);

    constructor() payable {

    }

    // 创建合约
    function createContract() external {
        // 构造函数是payable 可以在构建时支付一定的eth
        D d = new D{value:1}();
        d.setX(123);
        emit Log(address(d), d.x());
    }

    // 销毁自己, 发送余额给addr
    function destorySelf(address payable addr) external {
        selfdestruct(addr);
    }

    // 两种返回结构
    function returnsData1() external pure returns(string memory name, uint age){
        name = '123';
        age = 456;
        // return ('123',456);
    }

    function returnsData2() external pure returns(string memory, uint){
        string memory name = '123';
        uint age = 456;
        return (name, age);
    }

    // 外部函数有些类型无法返回
    // mapping
    // 指向storage的引用类型
    // 多维数组
    // 结构体
    mapping(uint => uint) mapData;
    string public strData;
    function externalReturn() external view returns(string memory){
        string storage strPtr = strData;
        return strPtr;
    }

    // 特殊的函数
    // 纯发送以太币的交易, data是空 会调用该方法
    receive() external payable {

    }

    // 1. 调用不存在的合约方法
    // 2. 纯发送以太币的交易且没有receive方法
    fallback() external payable{

    }

    /*
        状态可变性

        view 和 pure

        view保证不修改状态(可读)
        下列操作是修改状态的
        1. 直接修改状态变量
        2. 产生事件 emit event
        3. 创建其他合约 new Contract1();
        4. 调用selfdestruct
        5. 调用发送以太币 调用payable函数
        6. 调用没有标记为pure和view的函数
        7. 使用低级调用 send transfer call delegatecall staticcall
        8. 使用包含特定操作码的内链汇编

        读取状态变量
        1. 直接读取变量
        2. address.balance 或者 address.balance
        3. 访问tx block msg(除了msg.sig和msg.data之外)

        pure不读区任何状态变量

    */

    // 函数重载
    function foo(uint data, string memory name) external pure {

    }
    function foo(uint data, uint age) external pure{

    }


    // 事件 indexed标识可以用来在js中过滤事件
    event Log(string indexed name, uint indexed age, string sex);

}

contract Father{
    uint public a;

    function sayHi() external {

    }

    // virturl允许子类重写方法
    function sayNo() virtual external {

    }

}

abstract contract Mather{
    function sayLove() external {

    }

    // 没实现的函数, 子类要去实现的
    function sayH() virtual external;

}

// 使用is继承, 可以使用,多继承
contract Son is Father,Mather{

    function sayHello() external {
        
    }

    // override重写Father方法
    function sayNo() override external  {

    }

    function sayH() override external {

    }
}

