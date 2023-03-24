import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import {TransactionRequest} from "@ethersproject/providers";
import {Wallet} from "ethers";

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    const ONE_GWEI = 1_000_000_000;

    const lockedAmount = ONE_GWEI;
    const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Lock = await ethers.getContractFactory("Lock");
    const lock = await Lock.deploy(unlockTime, { value: lockedAmount });


    const Logic1 = await ethers.getContractFactory("Logic1");
    const logic1 = await Logic1.deploy();

    const Proxy1 = await ethers.getContractFactory("Proxy1");
    const proxy1 = await Proxy1.deploy(logic1.address,'0x0000000000000000000000000000000000000000');

    return { lock, unlockTime, lockedAmount, owner, otherAccount, logic1, proxy1};
  }

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      const { lock, unlockTime, logic1, proxy1, owner} = await loadFixture(deployOneYearLockFixture);
      // expect(await lock.unlockTime()).to.equal(unlockTime);
      // console.log(`logic1.address: ${logic1.address}`);
      // console.log(`before set value logic1.value: ${await logic1.value()}`);
      // logic1.setValue(1);
      // console.log(`after set value logic1.value: ${await logic1.value()}`);
      //
      // console.log(`proxy1.impl: ${await proxy1.impl()}`)
      // console.log(`logic1.addr: ${logic1.address}`)

      // console.log(`admin address: ${await proxy1.admin()}`)

      // 构造data
      // const data = await logic1.interface.encodeFunctionData(logic1.interface.getFunction("setValue"),["2"]);
      const data = await logic1.interface.encodeFunctionData("setValue",["0x1111111111111111111111111111111111111111111111111111111111111111"]);
      // console.log(`data:${data}`)
      const [ownerAddr] = await ethers.getSigners();
      const response = await ownerAddr.sendTransaction({
        to: proxy1.address,
        data: data
      });
      // console.log(`resp hash:${response.hash}`)

      // console.log(`after proxy set value logic1.value: ${await logic1.value()}`);

      console.log(`admin address: ${await proxy1.getAdmin()}`)
    });

    it("Should set the right owner", async function () {
      const { lock, owner } = await loadFixture(deployOneYearLockFixture);

      expect(await lock.owner()).to.equal(owner.address);
    });

    it("Should receive and store the funds to lock", async function () {
      const { lock, lockedAmount } = await loadFixture(
        deployOneYearLockFixture
      );

      expect(await ethers.provider.getBalance(lock.address)).to.equal(
        lockedAmount
      );
    });

    it("Should fail if the unlockTime is not in the future", async function () {
      // We don't use the fixture here because we want a different deployment
      const latestTime = await time.latest();
      const Lock = await ethers.getContractFactory("Lock");
      await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
        "Unlock time should be in the future"
      );
    });
  });

  describe("Withdrawals", function () {
    describe("Validations", function () {
      it("Should revert with the right error if called too soon", async function () {
        const { lock } = await loadFixture(deployOneYearLockFixture);

        await expect(lock.withdraw()).to.be.revertedWith(
          "You can't withdraw yet"
        );
      });

      it("Should revert with the right error if called from another account", async function () {
        const { lock, unlockTime, otherAccount } = await loadFixture(
          deployOneYearLockFixture
        );

        // We can increase the time in Hardhat Network
        await time.increaseTo(unlockTime);

        // We use lock.connect() to send a transaction from another account
        await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
          "You aren't the owner"
        );
      });

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
        const { lock, unlockTime } = await loadFixture(
          deployOneYearLockFixture
        );

        // Transactions are sent using the first signer by default
        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).not.to.be.reverted;
      });
    });

    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { lock, unlockTime, lockedAmount } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw())
          .to.emit(lock, "Withdrawal")
          .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
      });
    });

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).to.changeEtherBalances(
          [owner, lock],
          [lockedAmount, -lockedAmount]
        );


        if (typeof window !== 'undefined') {
          // 运行在浏览器中
          console.log('run in browse test file')
        } else {
          // 运行在Node.js环境中
          console.log('run in node.js test file')
        }

      });
    });
  });
});
