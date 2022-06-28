// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Voltreum_INRC is ERC20 {

    address voltreumCore;

    constructor() ERC20("Voltreum_INRC", "VOLTZ") {
        _mint(msg.sender, 1000 * 10 ** 18);
    }

    function assignCoreContractAddress(address _coreAddress) external {
        voltreumCore = _coreAddress;
    }

    function mint(uint256 amount) external {
        _mint(msg.sender, amount);
    }

    function approveTokenToVoltreum(uint _amount) external{
        approve(voltreumCore, _amount);
    }

}