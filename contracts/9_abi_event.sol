// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    像往常一样，负数会符号扩展填充，而不是零填充。 bytesNN 类型在右边填充，而 uintNN / intNN 在左边填充。

    注意:
    如果一个结构体包含一个以上的动态大小的数组，那么其编码会模糊有歧义。正因为如此，要经常重新检查事件数据，不能仅仅依靠索引参数的结果。
*/
contract AbiEvent{

    // anonymous 匿名的event
    // event Log(string name, uint num, uint[3] datas) anonymous;

    event Info(string name, uint num, uint[3] datas);
    event Warn(string name, uint indexed num, uint[3] datas);

    // 注解中的样例 应该是解码过的
    function foo() external {
        /*
            [
                {
                    "from": "0xB57ee0797C3fc0205714a577c02F7205bB89dF30",
                    "topic": "0x82758185e79c1f36b8d95b67d5ed5490dd13fb78ac9d25196fecda4015ab7ed9",
                    "event": "Info",
                    "args": {
                        "0": "this is info log event",
                        "1": "4",
                        "2": [
                            "1",
                            "2",
                            "3"
                        ],
                        "name": "this is info log event",
                        "num": "4",
                        "datas": [
                            "1",
                            "2",
                            "3"
                        ]
                    }
                }
            ]
        */
        emit Info("this is info log event", 4, [uint(1),uint(2),uint(3)]);

        /*
            [
                {
                    "from": "0xB57ee0797C3fc0205714a577c02F7205bB89dF30",
                    "topic": "0x54406af4270285c2bc6ef82ac067f1b6760afafe11e672e13d987c69b2f3c3da",
                    "event": "Warn",
                    "args": {
                        "0": "this is warn log event",
                        "1": "8",
                        "2": [
                            "5",
                            "6",
                            "7"
                        ],
                        "name": "this is warn log event",
                        "num": "8",
                        "datas": [
                            "5",
                            "6",
                            "7"
                        ]
                    }
                }
            ]
        */
        emit Warn("this is warn log event", 8, [uint(5),uint(6),uint(7)]);
    }

    /*
        返回topic
        0x84d8a21643295b804033dc60c8c45b557b841569dceefe9936abfa27fc17546a
    */
    function getTopics0() external pure returns(bytes32) {
        bytes memory data = "Log(string,uint256,uint256[3])";
        return keccak256(data);
    }
}