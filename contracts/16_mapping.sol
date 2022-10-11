// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    mapping只能在storage的位置上, 所以mapping可以是状态变量, 函数内的local storage引用.
    这个限制也存在于包含mapping类型的数组和结构体中

    mapping是无法遍历的, 但可以通过Wrapper Item包装
*/
contract TypsMapping {

    struct Person{
        string name;
        uint age;
        mapping(uint => Score) scoreMapping;
    }

    struct Score{
        string name;
        uint sort;
    }

    // 只能做为storage存储
    mapping(uint => Person) students;

    function setPerson(uint id, string calldata name, uint age) external {
        // 不允许这种方式创建, 因为Person(name,age)创建了memory类型Person, 而Person中包含了mapping
        // students[id] = Person(name,age);
        Person storage temp = students[id];
        temp.name = name;
        temp.age = age;
        // 字符串中只能是ascii码, 非unicode需要转换
        temp.scoreMapping[1] = Score(unicode"语文", 89);
    }

    /*
        获取不存在的key时, 返回0初始化的Person
    */
    function getValue(uint id) external view returns(string memory name, uint age){
        Person storage person = students[id];
        return (person.name, person.age);
    }

}