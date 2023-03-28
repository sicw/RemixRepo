import {time, loadFixture} from "@nomicfoundation/hardhat-network-helpers";
import {expect} from "chai";
import {ethers} from "hardhat";
import {BigNumber, EventFilter} from "ethers/lib.esm/ethers";

describe("function clash proxy", function () {

    async function deployOneFixture() {

        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const ownerAccountAddress = await owner.getAddress();
        const otherAccountAddress = await otherAccount.getAddress();

        console.log("owner:%s\nother:%s", ownerAccountAddress, otherAccountAddress)

        const BurnableToken = await ethers.getContractFactory("BurnableToken");
        const burnableToken = await BurnableToken.deploy();

        const ProxyFuncClashing = await ethers.getContractFactory("ProxyFuncClashing");
        const proxyFuncClashing = await ProxyFuncClashing.deploy(burnableToken.address);

        console.log("Proxy:%s\nLogic:%s", proxyFuncClashing.address, burnableToken.address)

        const proxyToken = await BurnableToken.attach(proxyFuncClashing.address);

        await proxyToken.initialize();

        await proxyToken.mint(otherAccountAddress, 1500);

        const decimals = await proxyToken.decimals()
        console.log(decimals)

        const name = await proxyToken.name()
        console.log(name)

        const symbol = await proxyToken.symbol()
        console.log(symbol)

        const totalSupply = await proxyToken.totalSupply()
        console.log(totalSupply.toString())

        let balance = await proxyToken.balanceOf(otherAccountAddress)
        console.log(balance.toString())

        await proxyToken.connect(otherAccount).burn('0x0000000000000000000000000000000100000000000000000000000000000000');

        balance = await proxyToken.balanceOf(otherAccountAddress)
        console.log(balance.toString())

        balance = await proxyToken.balanceOf(ownerAccountAddress)
        console.log(balance.toString())

        // console.log(JSON.stringify(proxyToken));


        //
        // let resp1 = await ProxyToken.connect(owner).mint(otherAccountAddress, 2000);
        // console.log(`mintResp.hash:${resp1.hash}`)
        //
        // let resp2 = await ProxyToken.connect(otherAccount).burn('0x0000000000000000000000000000000100000000000000000000000000000000');
        // console.log(`burn.hash:${resp2.hash}`)
        //
        // // 0x70a0823100000000000000000000000070997970c51812dc3a010c7d01b50e0d17dc79c8
        // const balanceOfABI = burnableToken.interface.encodeFunctionData("balanceOf",[otherAccountAddress])
        // console.log(`balanceOfABI:${balanceOfABI}`)
        //
        // const resp3 = await owner.call({
        //     to: proxyFuncClashing.address,
        //     data: balanceOfABI
        // })
        // console.log(`resp3:${resp3}`)
        //
        // const otherAmount = await ProxyToken.balanceOf('0x5B38Da6a701c568545dCfcB03FcB875f56beddC4');
        // console.log(`otherAmount:${otherAmount}`)

        // const balanceOf = burnableToken.interface.encodeFunctionData("balanceOf",['0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2']);
        // console.log(`balanceOf:${balanceOf}`)
        //
        // const mint = burnableToken.interface.encodeFunctionData("mint",['0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2',2000]);
        // console.log(`mint:${mint}`)
        //
        // const burn = burnableToken.interface.encodeFunctionData("burn",['0x0000000000000000000000000000000100000000000000000000000000000000']);
        // console.log(`burn:${burn}`)
        //
        // const collatePropagateStorage = proxyFuncClashing.interface.encodeFunctionData("collate_propagate_storage",['0x00000000000000000000000000000001']);
        // console.log(`burn:${collatePropagateStorage}`)

        // console.log(`msg.sender:${ownerAccountAddress} otherAccountAddress:${otherAccountAddress} mintResp hash:${mintResp.hash}`)

        return {
            proxyFuncClashing,
            burnableToken,
            owner,
            ownerAccountAddress,
            otherAccountAddress,
            otherAccount,
            proxyToken
        };
    }

    describe("Proxy", function () {

        // it("test token amounts", async function () {
        //     const {proxyFuncClashing, burnableToken, ownerAddress, otherAccountAddress} = await loadFixture(deployOneFixture);
        //     const otherAccountTokenAmount = await burnableToken.balanceOf(otherAccountAddress);
        //     // console.log(`otherAccountTokenAmount: ${JSON.stringify(otherAccountTokenAmount.toNumber())}`);
        //     expect(otherAccountTokenAmount.toNumber()).to.equal(2000);
        // })

        it("test address contract", async function () {
            const {proxyFuncClashing, otherAccountAddress, owner, burnableToken} = await loadFixture(deployOneFixture);
            // ProxyToken.connect(otherAccountAddress).burn(1000);

            // await ProxyToken.mint(otherAccountAddress, 2000);
            //
            // await ProxyToken.connect(owner).transfer(otherAccountAddress, 10000);
            //
            // const events = await burnableToken.queryFilter("Transfer")
            // console.log(JSON.stringify(events))
            //
            // const readData = await burnableToken.interface.encodeFunctionData("balanceOf", [otherAccountAddress]);
            // const readResponse = await owner.call({
            //     to: proxyFuncClashing.address,
            //     data: readData
            // });
            //
            // console.log(`readResponse:${readResponse}`)

            // const otherAccountTokenAmount = await ProxyToken.balanceOf(otherAccountAddress);
            // expect(otherAccountTokenAmount.toNumber()).to.equal(2000);

            // const ownerAccountTokenAmount = await ProxyToken.balanceOf(ownerAddress);
            // expect(ownerAccountTokenAmount.toNumber()).to.equal(1000);
        })

        // it("test user account burn tokens", async function () {
        //     const {proxyFuncClashing, burnableToken, ownerAddress, otherAccountAddress} = await loadFixture(deployOneFixture);
        //     // invoke logic code
        //     const data = await burnableToken.interface.encodeFunctionData("burn", [1000]);
        //     const [ownerAddr, otherAccount] = await ethers.getSigners();
        //     // data: 0x42966c6800000000000000000000000000000000000000000000000000000000000003e8
        //     const response = await otherAccount.sendTransaction({
        //         to: proxyFuncClashing.address,
        //         data: data
        //     });
        //     console.log(`otherAccount burn 1000 tokens hash: ${response.hash}`)
        //
        //     const otherAccountTokenAmount = await burnableToken.balanceOf(otherAccountAddress);
        //     expect(otherAccountTokenAmount.toNumber()).to.equal(1000);
        //
        //     const ownerAccountTokenAmount = await burnableToken.balanceOf(ownerAddress);
        //     expect(ownerAccountTokenAmount.toNumber()).to.equal(1000);
        // }).skip()
    })
});
