const { expect, assert } = require("chai");
const { ethers, BigNumber } = require("hardhat");
const { upgrades } = require("hardhat");


describe("Voltreum_Billing_Testing", function () {

    let voltContract;
    let voltAddress;
    let coreContract;
    let coreAddress;

    before(async () => {
        [admin, user1, user2, treasuryWallet] = await ethers.getSigners();
        console.log("Active Address:" + admin.address);

        const volt = await ethers.getContractFactory("Voltreum_INRC");
        voltContract = await volt.deploy();
        await voltContract.deployed();
        voltAddress = voltContract.address;
        console.log('volt  Passed');

        const core = await ethers.getContractFactory("VoltreumCore");
        coreContract = await core.deploy(voltAddress);
        await coreContract.deployed();
        coreAddress = coreContract.address;
        console.log('core Passed');

        await voltContract.assignCoreContractAddress(coreAddress);
        await voltContract.mint( ethers.utils.parseUnits("5000","ether"));
        await voltContract.connect(user1).mint( ethers.utils.parseUnits("500","ether"));

        console.log('Before Passed');
    })

    it('store bills', async () => {

        await coreContract.addbills(
            [user1.address , user2.address],
            [1000, 2000]
        );
        console.log('store bill Passed');

    })

    it('store payments', async () => {

        var bills = await coreContract.addpayments(
            [user1.address , user2.address],
            [10000, 20000]
        );
        console.log('store payment Passed');

    })

    it('check and do bill and payments', async () => {

        expect( await coreContract.bills(
           user1.address
        )).to.equal(ethers.utils.parseUnits("1000","ether"));

        expect( await coreContract.payments(
            user1.address
         )).to.equal(ethers.utils.parseUnits("10000","ether"));

         console.log('store check Passed');

        await voltContract.connect(user1).approveTokenToVoltreum(
            ethers.utils.parseUnits("500","ether")
        );
         
        await coreContract.connect(user1).payBill(
            ethers.utils.parseUnits("500","ether")
        );

        console.log('approve and pay');

        await voltContract.connect(admin).approve(coreAddress,             ethers.utils.parseUnits("5000","ether")
        );

        await coreContract.connect(user1).getPayment(
            ethers.utils.parseUnits("5000","ether")
        );

        console.log('bill payment Passed');

        expect( await coreContract.bills(
            user1.address
         )).to.equal(ethers.utils.parseUnits("500","ether"));
 
        expect( await coreContract.payments(
             user1.address
          )).to.equal(ethers.utils.parseUnits("5000","ether"));    

          console.log('bill payment check passed');
  
        //   expect( await voltContract.balanceOf(
        //     user1.address
        //  )).to.equal(5000);
 
        //  expect( await voltContract.balanceOf(
        //      admin.address
        //   )).to.equal(500);  

    })

    // it('Transferring Rented NFTs', async () => {

    //     await expect(filmrareContract.transferFrom(
    //         admin.address,
    //         user1.address,
    //         1
    //     )).to.be.revertedWith("Rented");

    //     await expect(filmrareContract.transferFrom(
    //         admin.address,
    //         user1.address,
    //         2
    //     )).not.to.be.reverted;

    // })

    // it(' Burn NFTs', async () => {

    //     await expect(filmrareContract.connect(user1).burn(
    //         1
    //     )).to.be.revertedWith("ERC721: caller is not token owner nor approved");

    //     await expect(filmrareContract.connect(user1).burn(
    //         2
    //     )).not.to.be.reverted;

    // })

    // it(' Change Admin', async () => {

    //     await expect(filmrareContract.connect(admin).changeAdmin(
    //         user1.address
    //     )).not.to.be.reverted;

    // })

    // it(' Grant Role ', async () => {

    //     await expect(filmrareContract.connect(admin).grantRole(
    //        "0xb19546dff01e856fb3f010c267a7b1c60363cf8a4664e21cc89c26224620214e",
    //        user1.address
    //     )).not.to.be.reverted;

    // })

    



})