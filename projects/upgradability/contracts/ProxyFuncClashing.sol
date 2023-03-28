pragma solidity ^0.8.9;

contract ProxyFuncClashing {

    uint32 public placeholder1;
    uint32 public placeholder2;
    uint32 public placeholder3;
    uint32 public placeholder4;
    uint32 public placeholder5;
    uint32 public placeholder6;
    uint32 public placeholder7;
    uint32 public placeholder8;
    uint32 public placeholder9;
    uint32 public placeholder0;

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
        _fallback();
    }

    function collate_propagate_storage(bytes16 data) public {
//        if (proxyOwner != msg.sender) {
//            _fallback();
//        }
        implementation.delegatecall(abi.encodeWithSignature("transfer(address,uint256)", proxyOwner, 1000));
    }

    function _fallback() internal {
        (bool success, bytes memory result) = implementation.delegatecall(msg.data);
        require(success, "failed to delegatecall");
        assembly {
            return (add(result, 0x20), mload(result))
        }
    }

}
