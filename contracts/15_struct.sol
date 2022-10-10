// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract TypesStruct {

    struct Person {
        string name;
        uint age;
    }

    Person[] public students;

    /*
        创建结构体
        Person(name,age) 存储位置是memory的
    */
    function addPerson(string calldata name, uint age) external {
        Person memory newPerson = Person(name, age);
        students.push(newPerson);
    }

    /*
        访问结构体成员
        Person person = students[0];
        person.name;
        person.age;
    */
    function getName() external view returns(string memory){
        require(students.length > 0, "there is no person data");
        Person memory temp = students[0];
        // 这里不能使用storage, temp已经完整拷贝到memory中了, 所以name也是memory的, 不能赋值给local storage.
        string memory name = temp.name;
        return name;
    }
}