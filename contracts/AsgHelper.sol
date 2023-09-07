//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./interfaces/ITRC20.sol";

contract ASGHelper {
    address public ASG;
    address constant POWERMINING = 0xb12c96b5f6d14e582c3EAc0d43B670f56Abd26f3;
    address constant STARAWARDS = 0x4073DbbB5727099F31c51dE9A64013DaFE6494BD;
    address constant COMMUNITY = 0xD2a147149aFAbD2baA614867604473C347B37fA4;
    address constant LPMINING = 0x73FfE5e14649D51eF0f79Fd25ef99B651489D7BD;
    address constant MERCHANTREWARDS = 0x727b356E968A337527C14F3470165F2c4260901D;
    address constant ASGMASTER = 0xbf32c53496c9a0ec7da11ef59f9b145f58c45c10;
    address constant MAST = 0xeae1ea1db294baf81c024bebb9b7048fa6410a82;
    address immutable owner;
    
    constructor(address _aaa) {
        ASG = _aaa;
        owner = msg.sender;
    }
    
    function transferASG() external returns (bool) {
        require(msg.sender == owner, "no");
        //1.285亿
        //128500000000000000000000000
        ITRC20(ASG).transfer(POWERMINING, 127400000*10**18);
        ITRC20(ASG).transfer(STARAWARDS, 100000*10**18);
        ITRC20(ASG).transfer(COMMUNITY, 200000*10**18);
        ITRC20(ASG).transfer(LPMINING, 500000*10**18);
        ITRC20(ASG).transfer(MERCHANTREWARDS, 100000*10**18);
        ITRC20(ASG).transfer(ASGMASTER, 1500000*10**18);
        ITRC20(ASG).transfer(MAST, 200000*10**18);
        return true;
    }
    
    function Airdrop(address _targetToken, address[] memory _users, uint256 _amount) external returns (bool) {
        require(msg.sender == owner, "no");
        uint len = _users.length;
        for (uint i=0; i < len; ++i) {
            ITRC20(_targetToken).transfer(_users[i], _amount);
        }
        return true;
    }
}