pragma solidity ^0.8.9;

contract Proxy1 {

    constructor(address _impl){
        impl = _impl;
    }

    address public impl;

    fallback() external {
        impl.delegatecall(msg.data);
    }
}
