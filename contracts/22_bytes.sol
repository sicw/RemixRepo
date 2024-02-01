// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

    function bytesTest1() public pure returns(uint) {
        bytes memory b = new bytes(2);
        return b.length;
    }

    function bytesTest12() public pure returns(uint) {
        bytes memory b = new bytes(2);
        b = 'abc';
        return b.length;
    }

    function bytesTest2() public pure returns(bytes1) {
        bytes memory b = new bytes(2);
        b = 'abc';
        return b[0];
    }

    function bytesTest3() public pure returns(bytes memory) {
        bytes memory b = new bytes(2);
        b = '000000';
        return b;
    }

    function bytesTest4(bytes calldata data) public pure returns(uint) {
        return data.length;
    }

    // solidity中没有字符串比较工具, 所以使用keccak256加密判断
    // 输入 0x1111 返回 true
    function bytesTest5(bytes calldata data) public view returns(bool) {
        bytes memory b = new bytes(2);
        b[0] = 0x11;
        b[1] = 0x11;
        return keccak256(abi.encodePacked(data)) == keccak256(abi.encodePacked(b));
    }
}