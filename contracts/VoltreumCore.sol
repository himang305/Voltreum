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

    function billPayment(uint256 _amount) external {
        ERC20(voltreumTokenAddress).transferFrom(msg.sender, owner, _amount);
    }

    function sendPayments(address[] calldata _to, uint256[] calldata _values) external {
        require(_to.length == _values.length);
        ERC20 erc20token = ERC20(voltreumTokenAddress);
        for (uint256 i = 0; i < _to.length; i++) {
            erc20token.transferFrom(msg.sender, _to[i], _values[i]);
        }
    }
}
