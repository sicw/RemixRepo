pragma solidity ^0.8.9;

contract Proxy1 {

    address public admin;

    address public impl;

    event Log(bool);

    constructor(address _impl, address _admin){
        impl = _impl;
        admin = _admin;
    }

    fallback() external {
        bool r;
        (r, ) = impl.delegatecall(msg.data);
        emit Log(r);
    }

    function upgradeTo(address _newImpl) public {
        require(msg.sender==admin,"only admin can upgrade impl address");
        impl = _newImpl;
    }
}
