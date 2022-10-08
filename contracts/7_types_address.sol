// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    地址类型有两种
    address             // 代表地址(EOA或者合约地址), 占用160bit = 20bytes
    address payable     // 可支付地址 有成员函数transfer和send
*/
contract AddressType{

    event Log(string name, address sender, uint value, bytes data);

    // 创建合约时需要支付一定费用
    constructor() payable {

    }

    // ----- 类型转换 ----- //  
    // address 与 合约 uint160 bytes20转换 字面量
    address public a = address(0x1111111122222222333333334444444455555555);
    
    address public b = address(uint160(123));
    uint160 public bb = uint160(b);

    address public c = address(bytes20(0x1111111122222222333333334444444455555555));
    bytes20 public cc = bytes20(c);

    address public d = address(this);

    // payable 与 合约 address转换
    // 转换成payable时, 对应的合约要有receive或者fallback方法
    address payable public e = payable(d);
    address payable public f = payable(this);
    // 从uint160转成address payable是不允许的, 需要先转换成address
    // address payable public g = payable(uint160(123));
    address payable public g = payable(address(uint160(123)));

    // 使用bytes32存储, 转为address时会有截断问题
    bytes32 public h = 0x1111111122222222333333334444444455555555666666667777777788888888;
    // 0x1111111122222222333333334444444455555555
    address public hh1 = address(bytes20(h));
    // 0x4444444455555555666666667777777788888888
    address public hh2 = address(uint160(uint256(h)));


    // ------- 地址类型成员变量 ------- //
    // 1. balance 查看地址余额单位wei
    function getBalance(address addr) external view returns(uint) {
        return addr.balance;
    }

    // 2. transfer 和 send
    // 这两个函数向合约发送eth, transfer在gas不足或调用栈超长是会报revert send在报错时会返回false不会报revert
    function transferEth(address payable addr, uint amount) external {
        // 从当前合约账户发送eth给addr
        addr.transfer(amount);
    }

    function sendEth(address payable addr, uint amount) external {
        // 从当前合约账户发送eth给addr
        bool ret = addr.send(amount);
        // 如果调用失败了gas费用还是要花的, 好比你打车去银行给别人转账, 因为你账户钱不够转账失败了. 但是打车钱还是要给的.
        require(ret == true);
    }

    // ----- call delegatecall staticcall  ----- //
    // 直接调用合约中方法 参数和返回值如: (bool, bytes) func(bytes);

    // call
    function call(address addr) external {
        bool status;
        bytes memory data;
        // todo 修改gas数量 这个gas数量不是计算出来的么, 为啥还要指定gas数量呢 限制最大值?
        // 发送以太币的数量 
        (status, data) = addr.call{gas:1000000, value:1 wei}(abi.encodeCall(FooContract.sum, (123, 123)));
        require(status);
        emit Log("AddressType callSum log", msg.sender, 0, data);
    }

    // delegatecall 被调函数中的上下文都是主调函数中的, msg、balance、storage等
    function delegateCall(address addr) external {
        // delegatecall 不能设置value
        (bool status, ) = addr.delegatecall{gas:1000000}(abi.encodeCall(FooContract.changeBBData,()));
        require(status);
        emit Log("AddressType delegateCall log", msg.sender, bb, "");
    }

    // staticcall 与call类似, 但是被调函数中不能修改状态变量 不然会报错
    // FooContract.changeBBData 中修改了bb的值, 所以会报revert
    function staticCall(address addr) external {
        // staticcall 不能设置value
        (bool status, ) = addr.staticcall{gas:1000000}(abi.encodeCall(FooContract.changeBBData,()));
        // (bool status, ) = addr.staticcall{gas:1000000}(abi.encodeCall(FooContract.staticFunc,()));
        require(status);
        emit Log("AddressType delegateCall log", msg.sender, bb, "");
    }

    // todo 模拟gas耗光 和 调用栈超长
    receive() external payable{

    }
}

contract FooContract {

    // delegatecall 保证合约状态变量和原状态变量布局相同
    address public a;
    address public b;
    uint160 public bb;

    event Log(string name, address sender, uint value, bytes data);

    function sum(uint add1, uint add2) external payable returns (uint) {
        emit Log("FooContract sum Log", msg.sender, msg.value, "");
        return add1 + add2;
    }

    function changeBBData() external {
        // 访问的msg.sender的数据
        bb = 250;
        emit Log("FooContract changeBBData Log", msg.sender, bb, "");
    }

    function staticFunc() external pure returns (uint){
        return 250;
    }

    function getCode(address addr) external view returns(bytes memory){
        return addr.code;
    }

    function getCodeHash(address addr) external view returns(bytes32){
        return addr.codehash;
    }

    receive() external payable{
        emit Log("FooContract receive Log", msg.sender, msg.value, "");      
    }

}