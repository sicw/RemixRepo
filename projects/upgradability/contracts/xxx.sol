pragma solidity ^0.8.9;

import './StorageSlot.sol';

contract Proxy {

    address public implement;

    constructor(address impl){
        implement = impl;
    }

    fallback() external payable {
        implementation.delegatecall(msg.data);
    }
}
