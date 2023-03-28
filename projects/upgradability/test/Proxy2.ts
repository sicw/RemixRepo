import {time, loadFixture} from "@nomicfoundation/hardhat-network-helpers";
import {anyValue} from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import {expect} from "chai";
import {ethers} from "hardhat";
import {TransactionRequest} from "@ethersproject/providers";
import {Wallet} from "ethers";
import {proxy} from "../typechain-types/@openzeppelin/contracts-upgradeable";

/**
 * npx hardhat test test/Proxy2.ts
 */
describe("Proxy2", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployOneYearLockFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const Logic2 = await ethers.getContractFactory("Logic2");
        const logic2 = await Logic2.deploy();

        const Logic3 = await ethers.getContractFactory("Logic2");
        const newLogic = await Logic2.deploy();

        const Proxy2 = await ethers.getContractFactory("Proxy2");
        const proxy2 = await Proxy2.deploy(logic2.address);

        const proxyLogic = Logic2.attach(proxy2.address);

        // 初始化admin 数据保留在proxy中
        await proxyLogic.init(owner.getAddress());

        return {owner, otherAccount, proxy2, proxyLogic, logic2, newLogic};
    }

    describe("test logic2", function () {
        it("get set", async function () {
            const {proxyLogic} = await loadFixture(deployOneYearLockFixture);
            let value = await proxyLogic.value();
            console.log(`before set data value:${value.toNumber()}`);
            await proxyLogic.setValue(7);
            value = await proxyLogic.value();
            console.log(`after set data value:${value.toNumber()}`);
        })

        it("upgrade to new logic impl addr", async function () {
            const {owner, proxyLogic, newLogic, proxy2} = await loadFixture(deployOneYearLockFixture);
            // 这里得用proxy去调, proxyLogic中没有getImplementation方法 typeError会报错
            console.log(`before change addr impl:${await proxy2.getImplementation()}`);
            await proxyLogic.connect(owner).upgradeTo(newLogic.address);
            console.log(`after change addr impl:${await proxy2.getImplementation()}`);
        })

        it("upgrade to new logic value", async function () {
            const {owner, otherAccount, proxyLogic, newLogic} = await loadFixture(deployOneYearLockFixture);
            await proxyLogic.setValue(7);
            let value = await proxyLogic.value();
            console.log(`before change addr value:${value.toNumber()}`);

            await proxyLogic.connect(owner).upgradeTo(newLogic.address);

            value = await proxyLogic.value();
            console.log(`after change addr value:${value.toNumber()}`);
        })

        it("isn't admin upgrade to new logic value", async function () {
            const {owner, otherAccount, proxyLogic, newLogic} = await loadFixture(deployOneYearLockFixture);
            await proxyLogic.setValue(7);
            let value = await proxyLogic.value();
            console.log(`before change addr value:${value.toNumber()}`);
            // only admin can upgrade impl address
            await expect(proxyLogic.connect(otherAccount).upgradeTo(newLogic.address)).to.be.revertedWith("failed to delegate call");
        })
    })
});
