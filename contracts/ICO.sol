// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Volt.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./TimeLock.sol";

/**
 * @title Seed/Pre-ICO Contract for VOLT Token
 * @dev For Seed round
 */
contract ICO {
    using SafeMath for uint256;

    Volt public voltContract;
    TimeLock public timelockContract;

    /// @dev Address where the ICO and Presales funds are collected
    address public reserveWallet;
    /// @dev Address of ICO admin to start different phases of ICOs and Presale
    address public icoAdmin;

    /// @dev Status of the ICO / Presale phase
    bool public saleActive;
    /// @dev Token Price in native token
    uint256 public tokenPrice;
    /// @dev Minimum purchase amount for investors during ICO / Presale of Volt token
    uint256 public investorMinCap;
    /// @dev Amount of wei raised till time
    uint256 public weiRaised;
    /// @dev Max token to be sold
    uint256 public targetAmount;

    /// @dev Mapping of contribution of investors
    mapping(address => uint256) public contributions;

    event TokenPurchase(address purchaser, uint256 amount, uint256 value);

    /**
     * @dev Constructor Function
     */
    constructor(Volt _voltContract, TimeLock _timelockContract) {
        investorMinCap = 10**18;
        reserveWallet = address(0xeD35D3276C6535A44fae66525CaAE6F8182eb9F1);
        timelockContract = _timelockContract;
        voltContract = _voltContract;
        icoAdmin = msg.sender;
        tokenPrice = 10**18;
        targetAmount = 50000000 * 10 ** 18;
    }

    /// @dev Modifier to allow access to ICO Admin only
    modifier onlyIcoAdmin() {
        require(msg.sender == icoAdmin, "Only Admin Allowed");
        _;
    }

    /// @dev Modifier to allow Token access in ICO active phases only
    modifier onlyWhileOpen() {
        require(saleActive == true, "Sale Closed");
        _;
    }

    /// @dev Receive function to receive funds send to contract directly
    receive() external payable {
        buyVoltFromNative(msg.sender);
    }

    /// @dev Fallback function to directly initiate token sale on BNB payment
    fallback() external payable {
        buyVoltFromNative(msg.sender);
    }

    /**
     * @dev Function to change sale status
     * @param status New sale status
     */
    function changeSaleStatus(bool status) external onlyIcoAdmin {
        saleActive = status;
    }

    /**
     * @dev Function to change target
     * @param _target New target
     */
    function changeTarget(uint256 _target) external onlyIcoAdmin {
        targetAmount = _target;
    }

    /**
     * @dev Function to change token price
     * @param _price New price of token
     */
    function changePrice(uint256 _price) external onlyIcoAdmin {
        tokenPrice = _price;
    }

    /**
     * @dev Function to change ICO admin
     * @param _newAdmin Address of new ICO Admin
     */
    function changeIcoAdmin(address _newAdmin) external onlyIcoAdmin {
        icoAdmin = _newAdmin;
    }

    /**
     * @dev Function to buy Volt token through BNB token
     * @param _beneficiary Address of investor
     */
    function buyVoltFromNative(address _beneficiary) public payable onlyWhileOpen {
        uint256 weiAmount = msg.value;
        require(weiAmount >= tokenPrice,"Invalid Value");
        payable(reserveWallet).transfer(weiAmount);
        _preValidatePurchase(_beneficiary);

        // calculate token amount to be created
        uint256 tokens = weiAmount / tokenPrice;

        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(msg.sender, weiAmount, tokens);
        _updatePurchasingState(_beneficiary, tokens);
    }

    /**
     * @dev Function to check benficiary address
     * @param _beneficiary Address of investor
     */
    function _preValidatePurchase(address _beneficiary) internal pure {
        require(_beneficiary != address(0));
    }

    /**
     * @dev Function to mint and send token to vesting contract in name of investor
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        voltContract.mint(address(timelockContract), _tokenAmount);
        timelockContract.initiateTokenLock(
            _beneficiary,
            _tokenAmount
        );
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed.
     * @param _beneficiary Address receiving the tokens
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        require(_tokenAmount >= investorMinCap, "Fail minimum investment");
        require(weiRaised.add(_tokenAmount) <= targetAmount, "Exceeded Target");
        weiRaised = weiRaised.add(_tokenAmount);
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Function to update investor contributions
     * @param _beneficiary Address receiving the tokens
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount)
        internal
    {
        contributions[_beneficiary] = contributions[_beneficiary].add(
            _weiAmount
        );
    }
}
