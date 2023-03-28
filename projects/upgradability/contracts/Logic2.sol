pragma solidity ^0.8.9;

import './StorageSlot.sol';

contract Logic2 {

    address public admin;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function upgradeTo(address _newImpl) public {
        require(msg.sender == admin, "only admin can upgrade impl address");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = _newImpl;
    }

    uint public value;

    function init(address _admin) external {
        admin = _admin;
    }

    // 都说了不要有自己的构造函数, admin内的数据在外面代理中读不到
//    constructor(address _admin){
//        admin = _admin;
//    }

    function setValue(uint _value) public {
        value = _value;
    }
}
