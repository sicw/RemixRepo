// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    Panic(uint) 和 Error(string)是内置的特殊函数

    assert / 溢出等 ---> Panic

    require / revert / index overflow等 ---> Error

    assert 用光gas (用于严重的错误)
    require revert返回剩余gas (基本的校验)
*/
contract Exception {

    uint public a;

    // 定义一个error, 类似event
    error CustomError(string message);

    event Log(string message, uint code);

    /*
        程序出错
        assert产生Painc对象
    */
    function assertDemo(bool flag) external pure {
        assert(flag);
    }

    /*
        用于验证参数, 调用返回值
        require 和 revert产生Error对象
    */
    function requireDemo(bool flag) external pure {
        // 返回error对象
        // require也是函数调用, 不论flag是什么, f()都会执行
        // require(flag, f());
        require(flag, "require msg");
    }

    function revertDemo() external pure {
        // revert("revert msg"); 类似于 revert error("revert msg")
        // 一般使用NoPermiseError()即可, 没有参数减少gas
        revert CustomError("custom error like event");
    }

    function tryCatch(address addr, uint flag) external returns (uint) {
        FooContract fooContract = FooContract(addr);
        // 调用方法并接收返回值
        try fooContract.foo(flag) returns (uint v) {
            a = a + v + 121;
        } 
        // 只能catch Error Panic 

        // assert("xxx") 或 require(false,"xxx") 或 内部错误 会执行这个catch
        catch Error(string memory err){
            string memory errStr = string.concat("catch Error:",err);
            emit Log(errStr, 0);
        }
        // assert(false) 或 x/0 或 overflow 或 arr[1111] index overflow 会执行这个catch
        catch Panic(uint code){
            emit Log("catch Panic", code);
        } 
        // revert() 或 require(false) 或 解码错误 执行这个catch
        catch (bytes memory data){
            string memory errStr = string.concat("catch ():",string(data));
            emit Log(errStr, 0);
        }
        return a;
    }
}

contract FooContract{

    error FooError(string message);

    // 发生错误后 a的更新会回退
    uint public a;

    function foo(uint flag) external returns(uint) {
        if(flag == 1) {
            a = 1;
            // Panic
            assert(false);
        } else if(flag == 2){
            a = 2;
            // 面外捕获不到CustomError
            // revert FooError("foo custom error");
            // Error
            revert("foo revert message");
        }else if(flag == 3){
            a = 3;
            // catch ()
            revert();
        } else if(flag == 4) {
            a = 4;
            // Error
            require(false,"foo require false");
        } else if(flag == 5){
            a = 5;
            // catch ()
            require(false);
        }
        a = 123;
        return a;
    }
}