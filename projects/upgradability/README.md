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
```代理合约

```
