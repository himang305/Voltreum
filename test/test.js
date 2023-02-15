const {
    expectEvent, // Assertions for emitted events
    time,
    expectRevert,
} = require("@openzeppelin/test-helpers");


const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Crypto_ICO_testing", function () {

    let voltContract;
    let voltAddress;
    let icoContract;
    let icoAddress;
    let gusdContract;
    let gusdAddress;
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
        console.log("Initializing");
        [owner, invest1, treasuryWallet] = await ethers.getSigners();
        console.log("Active Address:" + owner.address);

        const GUSD = await ethers.getContractFactory("GUSDToken");
        gusdContract = await GUSD.deploy();
        await gusdContract.deployed();
        gusdAddress = gusdContract.address;

        const volts = await ethers.getContractFactory("Volt");
        voltContract = await volts.deploy(treasuryWallet.address);
        await voltContract.deployed();
        voltAddress = voltContract.address;

        const Timelock = await ethers.getContractFactory("voltreum_Vesting");
        timelockContract = await Timelock.deploy(voltAddress);
        await timelockContract.deployed();
        timelockAddress = timelockContract.address;

        
        const ICO = await ethers.getContractFactory("voltreum_ICO");
        icoContract = await ICO.deploy( voltAddress, gusdAddress, timelockAddress, treasuryWallet.address );
        await icoContract.deployed();
        icoAddress = icoContract.address;
        console.log("0.1");


    })

    it("adding GUSD balance to user and iniitiate mint role",async function (){
        await gusdContract.connect(invest1).mint(invest1.address,"1000000000000000000000000");
        await gusdContract.connect(invest1).approve(icoAddress,"1000000000000000000000000");
        console.log("1");

        await icoContract.connect(owner).changeSaleStatus(true);
        await voltContract.connect(owner).mint(icoContract.address,"50000000000000000000000000")
        await timelockContract.connect(owner).setICOAddress(icoAddress);
        await icoContract.connect(invest1).buyVoltFromNative(invest1.address,"1000000000000000000000000") 
        console.log("2");
        
        let val = []
        val = await timelockContract.userDataIdView(invest1.address);
        console.log("entry", Number(val[0]));
        console.log("3");

        await time.increase(time.duration.days(30));
        await timelockContract.connect(invest1).releaseTokens(1);
        console.log("user balance after 30 days : ",  await voltContract.balanceOf(invest1.address));
        
         [a,
            b,
            c,
            amount,
            releasedAmount,
            unlockCount,
            d,e, withdrawcount] = await timelockContract.userData(1);
        console.log("30 days : ", ethers.utils.formatEther(releasedAmount));
        console.log("30 days : ", await timelockContract.userData(1));

        console.log("4");

        await time.increase(time.duration.days(35));
        await timelockContract.connect(invest1).releaseTokens(1);
        console.log("user balance after 65 days : ",  await voltContract.balanceOf(invest1.address));
        console.log("65 days : ", await timelockContract.userData(1));
         [a,
            b,
            c,
            amount,
            releasedAmount,
            unlockCount,
            d,e, withdrawcount] = await timelockContract.userData(1);
        console.log("65 days : ", ethers.utils.formatEther(releasedAmount));
        console.log("5");

        await time.increase(time.duration.days(25));
        await timelockContract.connect(invest1).releaseTokens(1);
        console.log("user balance after 90 days : ",  await voltContract.balanceOf(invest1.address));
        console.log("6");
        console.log("90 days : ", await timelockContract.userData(1));
         [a,
            b,
            c,
            amount,
            releasedAmount,
            unlockCount,
            d,e, withdrawcount] = await timelockContract.userData(1);
        console.log("90 days : ", ethers.utils.formatEther(releasedAmount));


        await time.increase(time.duration.days(90));
        await timelockContract.connect(invest1).releaseTokens(1);
        console.log("user balance after 180 days : ",  await voltContract.balanceOf(invest1.address));
        console.log("7");
        console.log("180 days : ", await timelockContract.userData(1));
         [a,
            b,
            c,
            amount,
            releasedAmount,
            unlockCount,
            d,e, withdrawcount] = await timelockContract.userData(1);
        console.log("180 days : ", ethers.utils.formatEther(releasedAmount));


        await time.increase(time.duration.days(185));
        await timelockContract.connect(invest1).releaseTokens(1);

        console.log("user balance after 365 days : ",  await voltContract.balanceOf(invest1.address));
        console.log("8");
        console.log("365 days : ", await timelockContract.userData(1));
         [a,
            b,
            c,
            amount,
            releasedAmount,
            unlockCount,
            d,e, withdrawcount] = await timelockContract.userData(1);
        console.log("365 days : ", ethers.utils.formatEther(releasedAmount));


    })

    // it("ICO Tests : ", async function () {


    //     await voltContract.mint(invest1.address, ethers.utils.parseUnits("100","ether")) 
        
    //     console.log("Supply : ", await voltContract.totalSupply());
    //     console.log("balance of investor 1 sh be 100 eth : ", await voltContract.balanceOf(invest1.address));

    //     await voltContract.connect(invest1).transfer(invest2.address, ethers.utils.parseUnits("50","ether")) 

    //     console.log("balance of investor 2 sh be 50 eth : ", await voltContract.balanceOf(invest2.address));

    //     await voltContract.changeFeeStatus(true, 5);

    //     await voltContract.connect(invest1).transfer(invest2.address, ethers.utils.parseUnits("50","ether")) 

    //     console.log("balance of investor 1 sh be 0 eth : ", await voltContract.balanceOf(invest1.address));
    //     console.log("balance of investor 2 sh be 0 eth : ", await voltContract.balanceOf(invest2.address));

    //     console.log("balance of treasury 50 eth 5%: ", await voltContract.balanceOf(treasuryWallet.address));

    //     await voltContract.mint(invest1.address, ethers.utils.parseUnits("1000000000","ether")) 
    //     console.log("etst- - - - - -");
    //     await voltContract.mint(invest1.address, ethers.utils.parseUnits("400000000","ether")) 


    //     // var openSale = await icoContract.changeSaleStatus(true);

    //     // var buyTokenFromBnb = await icoContract.connect(invest1).buyVoltFromNative(invest1.address, { value: ethers.utils.parseUnits("12","ether") });
    //     // await buyTokenFromBnb.wait();

    //     // expect(await timelockContract.lockAmount(invest1.address)).to.equal(ethers.utils.parseUnits("12","ether"));

    //     // expect(await voltContract.balanceOf(timelockContract.address)).to.equal(ethers.utils.parseUnits("12","ether"));

    //     // var reserveWallet = await icoContract.reserveWallet();

    //     // expect(await ethers.provider.getBalance(reserveWallet)).to.equal(ethers.utils.parseUnits("12","ether"));


    //     // var withdraw = await timelockContract.connect(invest1).releaseTokens();

    //     // console.log(await voltContract.balanceOf(invest1.address));
    //     // console.log(await voltContract.balanceOf(timelockContract.address));




    // });

});







