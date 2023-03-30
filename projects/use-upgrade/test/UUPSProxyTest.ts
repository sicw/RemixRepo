import {time, loadFixture} from "@nomicfoundation/hardhat-network-helpers";
import {BN, expectRevert, expectEvent, constants} from "@openzeppelin/test-helpers";
import {expect} from "chai";
import {ethers} from "hardhat";

describe("UUPS Test", function () {

    async function deployLogicFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const Logic3 = await ethers.getContractFactory("Logic3");
        const logic3 = await Logic3.deploy();

        const uupsProxyFactory = await ethers.getContractFactory("UUPSProxy");
        const uupsProxy = await uupsProxyFactory.deploy(logic3.address, "0x");

        const proxyMigration = Logic3.attach(uupsProxy.address);

        return {owner, otherAccount, uupsProxy, logic3, proxyMigration};
    }

    describe("Deployment", function () {
        it("Should set the right counter", async function () {
            const {owner, otherAccount, uupsProxy, logic, proxyMigration} = await loadFixture(deployLogicFixture);
            expect(await proxyMigration.current()).to.equal(0);
        });

        it("upgrade implement address", async function () {
            const {owner, otherAccount, uupsProxy, logic, proxyMigration} = await loadFixture(deployLogicFixture);
            await proxyMigration.increment();
            expect(await proxyMigration.current()).to.equal(1);

            const Logic4 = await ethers.getContractFactory("Logic4");
            const logic4 = await Logic4.deploy();
            await proxyMigration.upgradeTo(logic4.address);

            await Logic4.attach(uupsProxy.address).reset();

            expect(await proxyMigration.current()).to.equal(0);
        });

        it("", async function () {

        });
    });
});
