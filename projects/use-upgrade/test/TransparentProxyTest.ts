import {time, loadFixture} from "@nomicfoundation/hardhat-network-helpers";
import {anyValue} from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import {BN, expectRevert, expectEvent, constants} from "@openzeppelin/test-helpers";
import {expect} from "chai";
import {ethers} from "hardhat";

describe("Lock", function () {

    async function deployLogicFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        // 部署逻辑合约
        const Logic1 = await ethers.getContractFactory("Logic1");
        const logic1 = await Logic1.deploy();

        // 部署代理合约(并设置逻辑合约地址)
        const TUProxy = await ethers.getContractFactory("TransparentProxy");
        const tuProxy = await TUProxy.deploy(logic1.address, owner.getAddress(), "0x");

        const tuProxyMigration = Logic1.attach(tuProxy.address);

        return {owner, otherAccount, tuProxy, logic1, tuProxyMigration};
    }

    describe("Deployment", function () {

        it("Should set the right counter", async function () {
            const {otherAccount, tuProxyMigration} = await loadFixture(deployLogicFixture);
            // admin can not call current()
            expect(await tuProxyMigration.connect(otherAccount).current()).to.equal(0);
        });

        it("increment counter", async function () {
            const {otherAccount, tuProxyMigration} = await loadFixture(deployLogicFixture);
            await tuProxyMigration.connect(otherAccount).increment();
            expect(await tuProxyMigration.connect(otherAccount).current()).to.equal(1);
        });

        it("upgrade implement", async function () {
            const {owner, otherAccount, tuProxy, tuProxyMigration} = await loadFixture(deployLogicFixture);
            await tuProxyMigration.connect(otherAccount).increment();
            expect(await tuProxyMigration.connect(otherAccount).current()).to.equal(1);

            const newLogicFactory = await ethers.getContractFactory("Logic1");
            const newLogic = await newLogicFactory.deploy();
            await tuProxy.connect(owner).upgradeTo(newLogic.address);

            await tuProxyMigration.connect(otherAccount).increment();
            expect(await tuProxyMigration.connect(otherAccount).current()).to.equal(2);
        });

        it("upgrade implement add func", async function () {
            const {owner, otherAccount, tuProxy, tuProxyMigration} = await loadFixture(deployLogicFixture);
            await tuProxyMigration.connect(otherAccount).increment();
            expect(await tuProxyMigration.connect(otherAccount).current()).to.equal(1);

            const newLogicFactory = await ethers.getContractFactory("Logic2");
            const newLogic = await newLogicFactory.deploy();
            await tuProxy.connect(owner).upgradeTo(newLogic.address);

            const newLogicProxy = newLogicFactory.attach(tuProxy.address);
            await newLogicProxy.connect(otherAccount).decrement();
            expect(await newLogicProxy.connect(otherAccount).current()).to.equal(0);
        });
    });

    describe("revert", function () {
        it("not allow upgrade implement address with not admin", async function () {
            const {owner, otherAccount, tuProxy, tuProxyMigration} = await loadFixture(deployLogicFixture);
            const newLogicFactory = await ethers.getContractFactory("Logic1");
            const newLogic = await newLogicFactory.deploy();
            await expectRevert.unspecified(tuProxy.connect(otherAccount).upgradeTo(newLogic.address));
        });
    });

});
