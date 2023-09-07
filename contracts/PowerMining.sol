//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./interfaces/ITRC20.sol";
import "./interfaces/IAsgProfessionalManagers.sol";

interface IPowerMining {
    function disbursementOfProceeds(uint256 _amount) external returns (bool success);
    event DisbursementOfProceeds(uint256 amount);
}

contract PowerMining is IPowerMining {

    address immutable ADMINISTRATORS;
    address public revenueAddress; // 900 / 1000
    address public retirementAddress; //100 / 1000

    uint private lastWithdrawalTime;
    uint private lastWithdrawalAmount;

    constructor(address _administrators, address _revenueAddress, address _retirementAddress) {
        ADMINISTRATORS = _administrators;
        revenueAddress = _revenueAddress;
        retirementAddress = _retirementAddress;
    }

    function disbursementOfProceeds(uint256 _amount) external override returns (bool success) {
        require(IAsgProfessionalManagers(ADMINISTRATORS).isManager(msg.sender), "PowerMining: No permission");
        require(block.timestamp - lastWithdrawalTime >= 23 hours, "PowerMining: The proceeds have been paid out today");
        require(_amount <= 20000 * 10 ** 18, "PowerMining: The amount is incorrect");

        lastWithdrawalAmount = _amount;
        lastWithdrawalTime = block.timestamp;
        address asgAddress = IAsgProfessionalManagers(ADMINISTRATORS).asgAddress();
        uint asgBalance = ITRC20(asgAddress).balanceOf(address(this));
        if (_amount > asgBalance) _amount = asgBalance;
        emit DisbursementOfProceeds(_amount);
        ITRC20(asgAddress).transfer(retirementAddress, _amount * 100 / 1000);
        ITRC20(asgAddress).transfer(revenueAddress, _amount * 900 / 1000);
        success = true;
    }
    
    function setAddress(address _revenueAddress, address _retirementAddress) external {
        require(msg.sender == ADMINISTRATORS, "PowerMining: No permission");
        revenueAddress = _revenueAddress;
        retirementAddress = _retirementAddress;
    }
}