import {time, loadFixture} from "@nomicfoundation/hardhat-network-helpers";
import {expect} from "chai";
import {ethers} from "hardhat";

describe("Lock", function () {

    async function deployLogicFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const Logic = await ethers.getContractFactory("Logic1");
        const logic = await Logic.deploy();

        const MyUpgradeableBeacon = await ethers.getContractFactory("MyUpgradeableBeacon");
        const upgradeableBeacon = await MyUpgradeableBeacon.deploy(logic.address);

        const MyBeaconProxy = await ethers.getContractFactory("MyBeaconProxy");
        const beaconProxy1 = await MyBeaconProxy.deploy(upgradeableBeacon.address, "0x");
        const beaconProxy2 = await MyBeaconProxy.deploy(upgradeableBeacon.address, "0x");

        return {owner, otherAccount, upgradeableBeacon, beaconProxy1, beaconProxy2, Logic};
    }

    describe("Deployment", function () {
        it("Should set the right counter", async function () {
            const {owner, otherAccount, upgradeableBeacon, beaconProxy1, beaconProxy2, Logic} = await loadFixture(deployLogicFixture);
            expect(await Logic.attach(beaconProxy1.address).connect(otherAccount).increament()).to.equal(1);
            expect(await Logic.attach(beaconProxy2.address).connect(otherAccount).current()).to.equal(0);
        });

        it("upgrade implement address", async function () {
            const {owner, otherAccount, upgradeableBeacon, beaconProxy1, beaconProxy2, Logic} = await loadFixture(deployLogicFixture);

            await Logic.attach(beaconProxy1.address).increment();
            await Logic.attach(beaconProxy2.address).increment();

            expect(await Logic.attach(beaconProxy1.address).current()).to.equal(1);
            expect(await Logic.attach(beaconProxy2.address).current()).to.equal(1);
        });

    });
});
