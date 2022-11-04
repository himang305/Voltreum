// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./TeamTimeLock.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Volt.sol";

/**
 * @title Vesting Contract
 * @notice Used to assign and lock token for Internal Teams in TimeLock Contract
 * as per Vesting Schedule
 */
contract Vesting {
    using SafeMath for uint256;
    Volt public voltContract;
    TeamTimeLock public timelockContract;

    /// Token supply after the ICO assumed as 100% for token share of internal teams
    uint256 totalTokenSuppliedTillIco;
    /// Wallet Addresses of Internal teams of Voltreum
    address researchFund;
    address marketingFund;
    address legalTeamFund;
    address teamFund;
    address airdropFund;
    address reserveFund;
    address treasuryFund;

    address public owner;

    constructor(Volt _voltContract, TeamTimeLock _timelockContract) {
        owner = msg.sender;
        researchFund = address(0x9995e2d09adBaB13c81Da69701Ac72CF31f91f7e);
        marketingFund = address(0x03D3155cD23BbC4801AfDBD4a234788B5D856A50);
        legalTeamFund = address(0x427bED7CA25675447148D9dF5bA639d353dba8bF);
        teamFund = address(0xa4BC154619c93f50268fcc3bA5d716c3B506d1d3);
        airdropFund = address(0xeD35D3276C6535A44fae66525CaAE6F8182eb9F1);
        reserveFund = address(0xeD35D3276C6535A44fae66525CaAE6F8182eb9F1);
        treasuryFund = address(0xeD35D3276C6535A44fae66525CaAE6F8182eb9F1);

        voltContract = _voltContract;
        timelockContract = _timelockContract;
    }

    /**
     * @dev Function to execute token vesting process to Internal Teams
     */
    function doVesting() public {
        require(msg.sender == owner, " Only Owner allowed");

        uint256 researchAmount = 50000000 * 10**18;
        uint256 marketAmount = 120000000 * 10**18;
        uint256 legalAmount = 20000000 * 10**18;
        uint256 teamAmount = 100000000 * 10**18;
        uint256 airdropAmount = 10000000 * 10**18;
        uint256 reserveAmount = 250000000 * 10**18;
        uint256 treasuryAmount = 60000000 * 10**18;

        timelockContract.initiateTokenLock(reserveFund, 12, 12, reserveAmount);
        voltContract.mint(address(timelockContract), reserveAmount);

        timelockContract.initiateTokenLock(airdropFund, 5, 1, airdropAmount);
        voltContract.mint(address(timelockContract), airdropAmount);

        timelockContract.initiateTokenLock(treasuryFund, 4, 1, treasuryAmount);
        voltContract.mint(address(timelockContract), treasuryAmount);

        timelockContract.initiateTokenLock(marketingFund, 10, 1, marketAmount);
        voltContract.mint(address(timelockContract), marketAmount);

        timelockContract.initiateTokenLock(researchFund, 8, 1, researchAmount);
        voltContract.mint(address(timelockContract), researchAmount);

        timelockContract.initiateTokenLock(legalTeamFund, 4, 1, legalAmount);
        voltContract.mint(address(timelockContract), legalAmount);

        timelockContract.initiateTokenLock(teamFund, 12, 12, teamAmount);
        voltContract.mint(address(timelockContract), teamAmount);
    }
}
