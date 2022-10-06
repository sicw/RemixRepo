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
    // await web3.eth.getStorageAt('0x4c74F2533CBD1083392a856b8126597036dce235',0);
    // 0x11
    uint public count = 0x11;

    // slot1
    // address 20byte 基本类型使用不到一个slot时 会将多个字段合并到一个slot中
    // 拼接的顺序是从右向左存储
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
    // await web3.eth.getStorageAt('0x4c74F2533CBD1083392a856b8126597036dce235',2);
    // 0x1212121212121212121212121212121212121212121212121212121212121212
    bytes32 private password;

    // 不占用stroage空间
    uint public constant someConst = 0x44;

    // slot 3,4,5
    // bytes32是定长字节数组, b32Data也是定长数组, 其中没有push方法.
    bytes32[3] public b32Data;

    // slot 6
    // 0x121212999999888888777777666666555555444444333333222222111111
    uint24[10] public u24Datas;

    // slot 7
    // 不能补位, 数组和结构体单独使用一个slot, 并且下一个存储单元也必须是从新的slot开始
    uint16 public u16_2 = 0x4444;

    // slot 8 9
    // 数组和结构体都会使用新的slot
    // 内部字段紧密存储
    // slot 8
    // 0x1234
    // slot 9
    // 0x7373736868680000000000000000000000000000000000000000000000000000
    // 's' ascii 0x73
    // 'h' ascii 0x68
    User public oneUser;

    // bytes存储字符串和string存储字符串不同
    // bytes中最后一个字节没长度 string最后一个字节存长度
    struct User {
        uint id;
        bytes32 password;
    }

    // slot10 
    // 0x03 slot10存储的是动态数组的长度
    // 数据元素开始的位置在web3.utils.soliditySha3(slot)
    // 元素所在的位置web3.utils.soliditySha3(slot) + (index * elementSize)
    // 数组使用新的slot, 不论之前的slot剩余多大空间
    // await web3.eth.getStorageAt('0x4c74F2533CBD1083392a856b8126597036dce235',10); ==> 0x03
    // 计算数组起始偏移量
    // web3.utils.soliditySha3(10) ==> 0xc65a7bb8d6351c1cf70c95a316cc6a92839c986682d98bc35f958f4883f9d2a8
    // await web3.eth.getStorageAt('0x4c74F2533CBD1083392a856b8126597036dce235','0xc65a7bb8d6351c1cf70c95a316cc6a92839c986682d98bc35f958f4883f9d2a8');  ==> 0x01 User中的id
    // await web3.eth.getStorageAt('0x4c74F2533CBD1083392a856b8126597036dce235','0xc65a7bb8d6351c1cf70c95a316cc6a92839c986682d98bc35f958f4883f9d2a9');  ==> 0x6161610000000000000000000000000000000000000000000000000000000000 User中的password ‘aaa’
    // await web3.eth.getStorageAt('0x4c74F2533CBD1083392a856b8126597036dce235','0xc65a7bb8d6351c1cf70c95a316cc6a92839c986682d98bc35f958f4883f9d2aa');  ==> 0x02 User中的id
    // await web3.eth.getStorageAt('0x4c74F2533CBD1083392a856b8126597036dce235','0xc65a7bb8d6351c1cf70c95a316cc6a92839c986682d98bc35f958f4883f9d2ab');  ==> 0x6262620000000000000000000000000000000000000000000000000000000000 User中的password 'bbb'
    // await web3.eth.getStorageAt('0x4c74F2533CBD1083392a856b8126597036dce235','0xc65a7bb8d6351c1cf70c95a316cc6a92839c986682d98bc35f958f4883f9d2ac');  ==> 0x03 User中的id
    // await web3.eth.getStorageAt('0x4c74F2533CBD1083392a856b8126597036dce235','0xc65a7bb8d6351c1cf70c95a316cc6a92839c986682d98bc35f958f4883f9d2ad');  ==> 0x6363630000000000000000000000000000000000000000000000000000000000 User中的password 'ccc'
    User[] private users;

    // slot 11
    // 存储在高位字节(左对齐) 说明见slot12
    // 0x616263646566000000000000000000000000
    bytes18 str = "abcdef";

    // slot 12
    // 0x6162636461626364616263646162636461626364000000000000000000000028
    // 字符串没到32个字节(<=31), 左对齐存储在高位字节 最低位字节存储 长度*2 = 40
    string public str20 = 'abcdabcdabcdabcdabcd';

    // slot 13
    // string长度 > 31 slot 13中存储的是 长度*2 + 1 = 0x49 = 73
    // 实际存储位置
    // web3.utils.soliditySha3(13) ==> 0xd7b6990105719101dabeb77144f2a3385c8033acd3af97e9423a695e81ad1eb5
    // await web3.eth.getStorageAt('0x631e593796916353B83635118a573D1fC61261FA','0xd7b6990105719101dabeb77144f2a3385c8033acd3af97e9423a695e81ad1eb5'); 
    // 0x6162636461626364616263646162636461626364616263646162636461626364 这种情况就不是左对齐了(右对齐 从低位字节开始存储)
    string public str36 = 'abcdabcdabcdabcdabcdabcdabcdabcdabcd';

    // slot 14
    bytes32 b32 = 0x1111111111111111111111111111111111111111111111111111111111111111;

    // slot 15
    // await web3.eth.getStorageAt('0x631e593796916353B83635118a573D1fC61261FA',15); ==> 0x02 数组长度是2
    // a[i][j]二维数组寻址
    // 开始位置 web3.utils.soliditySha3(web3.utils.soliditySha3(slot) + i) + j
    // web3.utils.soliditySha3(15)
    // await web3.eth.getStorageAt('0x631e593796916353B83635118a573D1fC61261FA',web3.utils.soliditySha3('0x8d1108e10bcb7c27dddfc02ed9d693a074039d026cf4ea4240b40f7d581ac802')); 
    // "0x333333222222111111" 在同一个slot中, 拼接多个字段时 从右向左排列.
    /*
        uint24 a = 0x111111;
        uint24 b = 0x222222;
        uint24 c = 0x333333;
        内存存储:
        0x333333 | 222222 | 111111
    */
    uint24[][] public datas3;

    // slot 16 17
    // slot16 ==> 0x01
    // slot17 ==> 0x01
    // datas2的一维数组是定长的2 定长数组是顺序排列的, 定长数组中每个元素的动态数组, 所以定长数组中元素内容是动态数组的长度
    // web3.utils.soliditySha3(16) 第一个数组的开始位置 
    // web3.utils.soliditySha3(17) 第二个数组的开始位置
    uint24[][2] public datas2;

    // slot 18 19
    // [元素1 , 元素2]
    // [ [uint24, uint24, uint24] , [uint24, uint24, uint24] ]
    // 数组和结构体单独使用一个slot, 所以一维数组不能共用同一个slot 
    // 同一个数组中 不满足32byte 共用同一个slot
    // slot[8] ==> 0xeeeeeeffffffeeeeee
    // slot[9] ==> 0xffffffeeeeeeffffff
    uint24[3][2] public datas1;

    // slot 20
    // bytes动态数组 存储小于32byte时, 左对齐, 最后一个字节存储的是 长度 * 2
    bytes public bs;

    // slot 21
    // 类似bytes 存储小于32byte时, 左对齐, 最后一个字节存储的是 长度 * 2
    string public name;

    // slot 22
    // mapping的slot为空
    // 对应key的存储位置web3.utils.soliditySha3(key, slot)
    // web3.utils.soliditySha3(0,22) ==> 0x0263c2b778d062355049effc2dece97bc6547ff8a88a3258daa512061c2153dd
    // await web3.eth.getStorageAt('0x631e593796916353B83635118a573D1fC61261FA','0x0263c2b778d062355049effc2dece97bc6547ff8a88a3258daa512061c2153dd'); 
    // web3.utils.soliditySha3(1,22) ==> 0x4c4dc693d7db52f85fe052106f4b4b920e78e8ef37dee82878a60ab8585faf49
    // await web3.eth.getStorageAt('0x631e593796916353B83635118a573D1fC61261FA','0x4c4dc693d7db52f85fe052106f4b4b920e78e8ef37dee82878a60ab8585faf4a'); 
    mapping(uint => User) private idToUser;

    constructor(bytes32 _password) {
        password = _password;

        b32Data[0] = 0x1111111111111111111111111111111111111111111111111111111111111111;
        b32Data[1] = 0x2222222222222222222222222222222222222222222222222222222222222222;
        b32Data[2] = 0x3333333333333333333333333333333333333333333333333333333333333333;

        u24Datas[0] = 0x111111;
        u24Datas[1] = 0x222222;
        u24Datas[2] = 0x333333;
        u24Datas[3] = 0x444444;
        u24Datas[4] = 0x555555;
        u24Datas[5] = 0x666666;
        u24Datas[6] = 0x777777;
        u24Datas[7] = 0x888888;
        u24Datas[8] = 0x999999;
        u24Datas[9] = 0x121212;

        // 创建临时的memoty结构体, 并拷贝到storage中
        // 指定字段存储:
        // oneUser = User({id:0x123,password:"ssshhh"});
        oneUser = User(0x1234, "ssshhh");

        users.push(User(0x01, "aaa"));
        users.push(User(0x02, "bbb"));
        users.push(User(0x03, "ccc"));

        uint24[] memory e1 = new uint24[](3);
        e1[0] = 0x111111;
        e1[1] = 0x222222;
        e1[2] = 0x333333;
        datas3.push(e1);

        uint24[] memory e2 = new uint24[](4);
        e2[0] = 0x555555;
        e2[1] = 0x666666;
        e2[2] = 0x777777;
        datas3.push(e2);

        // datas2不具有push方法, 内部数组是动态的有push方法
        datas2[0].push(0xaaaaaa);
        datas2[1].push(0xbbbbbb);
        // push not found
        // datas2.push();

        // 二维数数组的定义和查询 行和列是相反的???
        datas1[0][0] = 0xeeeeee;
        datas1[0][1] = 0xffffff;
        datas1[0][2] = 0xeeeeee;
        datas1[1][0] = 0xffffff;
        datas1[1][1] = 0xeeeeee;
        datas1[1][2] = 0xffffff;

        bs.push(0x22);
        bs.push(0x33);

        name = "ssssss";

        idToUser[0] = User(0x1122,"ssshhh");
        idToUser[1] = User(0x3344,"aaabbb");        
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

    receive() external payable {}
}