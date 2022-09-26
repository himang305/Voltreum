const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Crypto_ICO_testing", function () {
    let voltContract;
    let voltAddress;
    let icoContract;
    let icoAddress;
    let vestingContract;
    let vestingAddress;
    let timelockContract;
    let timelockAddress;
    let owner;
    let invest1;
    let invest2;
    let tokenWallet;
    let treasuryWallet;

    beforeEach(async function () {

        [owner, invest1, treasuryWallet] = await ethers.getSigners();
        console.log("Active Address:" + owner.address);

        const volts = await ethers.getContractFactory("Volt");
        voltContract = await volts.deploy();
        await voltContract.deployed();
        voltAddress = voltContract.address;
        console.log(555);
        
        const Timelock = await ethers.getContractFactory("TimeLock");
        timelockContract = await Timelock.deploy(voltAddress);
        await timelockContract.deployed();
        timelockAddress = timelockContract.address;

        console.log(313);
        const ICO = await ethers.getContractFactory("ICO");
        icoContract = await ICO.deploy( voltAddress, timelockAddress);
        await icoContract.deployed();
        icoAddress = icoContract.address;

        var giveMinterRoleToIco = await voltContract.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6", icoAddress );
        console.log("Done prereq");

        var addLockerICO = await timelockContract.changeLockers(icoAddress);

    })

    it("ICO Tests : ", async function () {

        
        var openSale = await icoContract.changeSaleStatus(true);

        var buyTokenFromBnb = await icoContract.connect(invest1).buyVoltFromNative(invest1.address, { value: ethers.utils.parseUnits("12","ether") });
        await buyTokenFromBnb.wait();

        expect(await timelockContract.lockAmount(invest1.address)).to.equal(ethers.utils.parseUnits("12","ether"));

        expect(await voltContract.balanceOf(timelockContract.address)).to.equal(ethers.utils.parseUnits("12","ether"));

        var reserveWallet = await icoContract.reserveWallet();

        expect(await ethers.provider.getBalance(reserveWallet)).to.equal(ethers.utils.parseUnits("12","ether"));


        var withdraw = await timelockContract.connect(invest1).releaseTokens();

        console.log(await voltContract.balanceOf(invest1.address));
        console.log(await voltContract.balanceOf(timelockContract.address));




    });

});




