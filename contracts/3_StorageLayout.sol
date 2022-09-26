// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    evm使用32byte的slot存储数据, 共有2**256个solt(寻址时使用32byte长度的地址)
    0byte                                31byte
    | -------- -------- -------- -------- |     slot 0
    | -------- -------- -------- -------- |     slot 1
    | -------- -------- -------- -------- |     slot 2
    | -------- -------- -------- -------- |     slot 3
*/
contract StorageLayout {

    // slot0
    // uint = uint256 共32字节
    uint public count = 0x11;

    // slot1
    // address 20byte 基本类型使用不到一个slot时 会将多个字段合并到一个slot中
    //    u24   u16 isTrue          owner
    // | 333333 2222 01 1234567890123456789012345678901234567890 |
    address public owner = msg.sender;
    // bool 占用1byte
    bool public isTrue = true;
    // uint16 占用2byte
    uint16 public u16 = 0x2222;
    // uint 24 占用3byte
    uint24 public u24 = 0x333333;

    // slot2
    // slot1中还剩6type存不下32byte 所以使用新的slot
    bytes32 private password;

    // 不占用stroage空间
    uint public constant someConst = 123;

    // slot 3,4,5
    // 定长数组按顺序排
    bytes32[3] public b32Data;

    // slot 6
    // 定长数组按顺序排???
    uint24[10] public u24Datas;

    // 看看能否补位
    uint16 public u16_2 = 0x4444;

    // 单个结构体偏移量???
    User public oneUser;

    struct User {
        uint id;
        bytes32 password;
    }

    // slot8
    // 动态数组slot8存储数组的长度
    // 数据元素开始的位置在web3.utils.soliditySha3(slot)
    // 元素所在的位置web3.utils.soliditySha3(slot) + (index * elementSize)
    // 动态数组使用新的slot, 不论之前的slot剩余多大空间
    User[] private users;

    // a[i][j]二维数组寻址
    // 开始位置 web3.utils.soliditySha3(web3.utils.soliditySha3(slot) + i) + j
    // web3.utils.soliditySha3(slot) + i是第多少个插槽??? 里面存储的对应数组的长度???
    uint24[][] public datas3;

    // 一维数组顺序排列 二维数组动态sha3映射???
    uint24[][5] public datas2;

    // 固定数组按顺序排列???
    uint24[2][3] public datas1;

    // bytes类似byte1[] 是一个动态数组
    bytes public bs;
    // 跟bytes是一样的 但没有存储长度和push方法
    string public name;

    // mapping的slot为空
    // 对应key的存储位置web3.utils.soliditySha3(key, slot)
    mapping(uint => User) private idToUser;

    constructor(bytes32 _password) {
        password = _password;
        name = "ssssss";
        bs.push(0x22);
        bs.push(0x33);
    }

    function addUser(bytes32 _password) public {
        User memory user = User({id: users.length, password: _password});
        users.push(user);
        idToUser[user.id] = user;
    }

    function getArrayLocation(
        uint slot,
        uint index,
        uint elementSize
    ) public pure returns (uint) {
        return uint(keccak256(abi.encodePacked(slot))) + (index * elementSize);
    }

    function getMapLocation(uint slot, uint key) public pure returns (uint) {
        return uint(keccak256(abi.encodePacked(key, slot)));
    }

    receive() external payable {

    }
}