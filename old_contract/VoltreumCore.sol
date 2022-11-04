// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VoltreumCore {
    address voltreumTokenAddress;
    address owner;

    constructor(address _token) {
        voltreumTokenAddress = _token;
        owner = msg.sender;
    }

    mapping(address => uint256) public bills;
    mapping(address => uint256) public payments;

    event Bill(address indexed _from, uint256 _value);
    event Payment(address indexed _from, uint256 _value);
    event Paid(address indexed _from, uint256 _value);
    event Withdraw(address indexed _from, uint256 _value);

    function addbills(
        address[] calldata _userAddress,
        uint256[] calldata _bills
    ) external {
        require(_userAddress.length == _bills.length, "incorrect data");
        for (uint256 i = 0; i < _userAddress.length; i++) {
            bills[_userAddress[i]] =
                bills[_userAddress[i]] +
                _bills[i] *
                10**18;
            emit Bill(_userAddress[i], _bills[i]);    
        }
    }

    function addpayments(
        address[] calldata _userAddress,
        uint256[] calldata _payments
    ) external {
        require(_userAddress.length == _payments.length, "incorrect data");
        for (uint256 i = 0; i < _userAddress.length; i++) {
            payments[_userAddress[i]] =
                payments[_userAddress[i]] +
                _payments[i] *
                10**18;
        emit Payment(_userAddress[i], _payments[i]);
        }
    }

    function payBill(uint256 _amount) external {
        ERC20(voltreumTokenAddress).transferFrom(msg.sender, owner, _amount);
        bills[msg.sender] = bills[msg.sender] - _amount;
        emit Paid(msg.sender, _amount);
    }

    function getPayment(uint256 _amount) external {
        require(payments[msg.sender] >= _amount, "Exceeded payment amount");
        ERC20(voltreumTokenAddress).transferFrom(owner, msg.sender, _amount);
        payments[msg.sender] = payments[msg.sender] - _amount;
        emit Withdraw(msg.sender, _amount);
    }
}
