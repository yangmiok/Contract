//SPDX-License-Identifier: MIT;
pragma solidity 0.8.6;

interface IASG {
    function burn(uint256 amount) external returns(bool success);
}