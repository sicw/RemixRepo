pragma solidity ^0.8.9;

import './StorageSlot.sol';

contract Proxy1 {

    //    address public admin;
    //
    //    address public impl;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 internal constant _ADMIN_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d3a2bbc;

    event Log(bool);

    constructor(address _impl, address _admin){
        setImplementation(_impl);
        setAdmin(_admin);
    }

    fallback() external {
        (bool success, bytes memory result) = getImplementation().delegatecall(msg.data);
        require(success, "Failed to delegatecall");
        emit Log(success);
        assembly {
            return(add(result, 0x20), mload(result))
        }
    }

    function upgradeTo(address _newImpl) public {
        require(msg.sender == getAdmin(), "only admin can upgrade impl address");
        setImplementation(_newImpl);
    }

    function getImplementation() public view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function setImplementation(address newImplementation) public {
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function getAdmin() public view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function setAdmin(address newAdmin) public {
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

}
