//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./interfaces/ITRC20.sol";

contract UUU is ITRC20 {
    string public constant name = "UUU";
    string public constant symbol = "UUU";
    uint8 public constant decimals = 6;
    uint256 public override totalSupply = 100000000000000000000 * 10**decimals;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;
    
    constructor() {
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function balanceOf(address account) external view override returns(uint256 balance) {
        balance = balances[account];
    }
    
    function allowance(address account, address spender) external view override returns(uint256){
        return allowances[account][spender];
    }
    
    function transfer(address recipient, uint256 amount) external override returns(bool success) {
        require(recipient != address(0), "USDT:The destination address must not be 0");
        require(amount > 0, "USDT: amount must be greater than 0");
        require(balances[msg.sender] >= amount, "USDT: Insufficient balance");
        
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        success = true;
    }
    
    function approve(address spender, uint256 amount) external override returns(bool success) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        success = true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external override returns(bool success){
        require(recipient != address(0), "USDT: The destination address must not be 0");
        require(amount > 0, "USDT: amount must be greater than 0");
        require(allowances[sender][msg.sender] >= amount, "USDT:Insufficient authorization");
        require(balances[sender] >= amount, "USDT:Insufficient balance");
        
        allowances[sender][msg.sender] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        success = true;
    }
}