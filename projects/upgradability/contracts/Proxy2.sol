pragma solidity ^0.8.9;

import './StorageSlot.sol';


/**
    UUPS代理合约, 升级函数在logic中
*/
contract Proxy2 {

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address _impl){
        setImplementation(_impl);
    }

    fallback() external {
        (bool success, bytes memory result) = getImplementation().delegatecall(msg.data);
        require(success, "failed to delegate call");
        // 这里添加返回值, 再使用call调用时返回结果
        assembly {
            return(add(result, 0x20), mload(result))
        }
    }

    function getImplementation() public view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function setImplementation(address newImplementation) public {
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }
}
