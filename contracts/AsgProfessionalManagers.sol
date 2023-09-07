//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./interfaces/IAsgProfessionalManagers.sol";

contract AsgProfessionalManagers is IAsgProfessionalManagers{

    address owner;
    address public override verifyAddress;
    address public override asgAddress;
    mapping(address => bool) public override isManager;

    modifier onlyOwner() {
        require(msg.sender == owner, "Administrators: No permission");
        _;
    }

    constructor(address _verifyAddress, address _asgAddress) {
        verifyAddress = _verifyAddress;
        asgAddress = _asgAddress;
        isManager[msg.sender] = true;
        owner = msg.sender;
    }

    function setVerifyAddress(address _verifyAddress) external override onlyOwner returns (bool) {
        verifyAddress = _verifyAddress;
        return true;
    }

    function setAsgAddress(address _asgAddress) external override onlyOwner returns (bool) {
        asgAddress = _asgAddress;
        return true;
    }

    function transferOwnership(address newOwner) public virtual override onlyOwner returns (bool) {
        require(newOwner != address(0), "Administrators: new owner is the zero address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
        return true;
    }

    function setManager(address manager) external  onlyOwner returns (bool) {
        if (isManager[manager]) {
            isManager[manager] = false;
        } else {
            isManager[manager] = true;
        }
        return true;
    }

    function setParams(address target, bytes calldata callData) external payable override onlyOwner returns (bool) {
        (bool success, ) = target.call{value: msg.value}(callData);
        if (success) {
            return true;
        }
        revert("Administrators: setParams Failed");
    }
}