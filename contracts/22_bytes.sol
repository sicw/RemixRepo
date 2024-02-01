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
}