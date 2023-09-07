//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;


interface IAsgProfessionalManagers {
    event OwnershipTransferred(address oldOwner, address newOwner);

    function verifyAddress() external view returns (address);
    function asgAddress() external view returns (address);
    function isManager(address) external view returns (bool);
    function setVerifyAddress(address _verifyAddress) external returns (bool);
    function setAsgAddress(address _asgAddress) external returns (bool);
    function transferOwnership(address newOwner) external returns (bool);
    function setParams(address target, bytes calldata callData) external payable returns (bool);
}