// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiaries to extract the tokens after a given release schedule
 * Exponential release of token
 */
contract TimeLock is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public voltContract;

    address public admin;
    /// @dev Address of contract who can lock token: ICO and Vesting
    address public lockers;

    /// @dev Mapping to track release time of each month
    mapping(address => uint256) public releaseTime;
    /// @dev Mapping to track release time of each month
    mapping(address => uint256) public releaseMonth;
    mapping(address => uint256) public investedAmount;
    /// @dev Mapping to track locked amount of each investor
    mapping(address => uint256) public lockAmount;

    mapping(uint256 => uint256) public percentReleasePowerFive;
    event InitiateLock(address user, uint256 value);
    event ReleaseLock(address user, uint256 value);
    event ChangeLocker(address);

    /**
     * @dev Constructor Function to add Volt Token Address
     */
    constructor(IERC20 _token) {
        // lockers = msg.sender;  only testing
        voltContract = _token;
        admin = msg.sender;
        percentReleasePowerFive[1] = 100225;
        percentReleasePowerFive[2] = 226;
        percentReleasePowerFive[3] = 453;
        percentReleasePowerFive[4] = 912;
        percentReleasePowerFive[5] = 1848;
        percentReleasePowerFive[6] = 3797;
        percentReleasePowerFive[7] = 8017;
        percentReleasePowerFive[8] = 17874;
        percentReleasePowerFive[9] = 44476;
        percentReleasePowerFive[10] = 138400;
        percentReleasePowerFive[11] = 683772;
        percentReleasePowerFive[12] = 9000000;
    }

    /// @dev Modifier to allow access to Lockers only
    modifier onlyLockers() {
        require(msg.sender == lockers, "Only Lockers Allowed");
        _;
    }

    /**
     * @dev Function to set Lockers
     * @param  _lockers Address of lockers
     */
    function changeLockers(address _lockers) external {
        require(msg.sender == admin, "Only Admin allowed");
        require(_lockers != address(0), "Invalid address");
        lockers = _lockers;
        emit ChangeLocker(_lockers);
    }

    /**
     * @dev Function to set new admin
     * @param  _admin Address of lockers
     */
    function changeAdmin(address _admin) external {
        require(_admin != address(0), "Invalid address");
        require(msg.sender == admin, "Only Admin allowed");
        admin = _admin;
    }

    /**
     * @dev Function to initiate token lock process
     * @param _beneficiary Owner of the locked tokens
     * @param _amount The amount of tokens to lock
     */
    function initiateTokenLock(address _beneficiary, uint256 _amount)
        public
        onlyLockers
    {
        lockAmount[_beneficiary] = lockAmount[_beneficiary] + _amount;
        investedAmount[_beneficiary] = investedAmount[_beneficiary] + _amount;
        releaseTime[_beneficiary] = block.timestamp;
        // releaseMonth[_beneficiary] = 0;
        emit InitiateLock(_beneficiary, _amount);
    }

    function calculateReleaseAmount(address _beneficiary)
        public
        view
        returns (uint256)
    {
        uint256 months = calculateMonthsPassed(_beneficiary);
        uint256 amount = 0;
        for (uint256 i = 1; i <= months && i < 13; i++) {
            amount += investedAmount[_beneficiary]
                .mul(percentReleasePowerFive[releaseMonth[_beneficiary] + i])
                .div(1e7);
        }
        return amount;
    }

    function calculateMonthsPassed(address _beneficiary)
        public
        view
        returns (uint256)
    {
        uint256 month = block.timestamp.sub(releaseTime[_beneficiary]);
        return month.div(86400 * 30);
        // return month.div(120);
    }

    function releaseTokens() external nonReentrant {
        uint256 amount = 0;
        uint256 months = calculateMonthsPassed(msg.sender);
        if (months > 0) {
            amount = calculateReleaseAmount(msg.sender);
            releaseTime[msg.sender] += 86400 * 30 * months;
            // releaseTime[msg.sender] += 120 * months;
            releaseMonth[msg.sender] += months;

            if (amount <= lockAmount[msg.sender]) {
                lockAmount[msg.sender] -= amount;
                voltContract.safeTransfer(msg.sender, amount);
                emit ReleaseLock(msg.sender, amount);
            }
        }
    }

    function withdrawTokenAdmin(uint256 _amount) external {
        require(msg.sender == admin, "Only Admin allowed");
        voltContract.safeTransfer(msg.sender, _amount);
    }
}
