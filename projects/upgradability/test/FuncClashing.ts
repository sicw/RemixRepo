import {loadFixture} from "@nomicfoundation/hardhat-network-helpers";
import {ethers} from "hardhat";

/**
 * 验证函数选择器冲突, 合约在contracts/func-clashing中
 * 执行命令: npx hardhat test test/FuncClashing.ts
 */
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
