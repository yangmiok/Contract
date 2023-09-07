//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./interfaces/ITRC20.sol";

contract ASG is ITRC20 {
    string public constant name = "Ecological chain of consumption";
    string public constant symbol = "ASG";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply = 130000000 * 10**decimals;
    uint256 public burnLimit = 13000000 * 10**decimals;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;
    
    constructor () {
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
        if (recipient == address(0)) {
            return burn(msg.sender, amount);
        }
        require(amount > 0, "ASG: amount must be greater than 0");
        require(balances[msg.sender] >= amount, "ASG: Insufficient balance");
        
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
        require(recipient != address(0), "ASG: The destination address must not be 0");
        require(amount > 0, "ASG: amount must be greater than 0");
        require(allowances[sender][msg.sender] >= amount, "ASG:Insufficient authorization");
        require(balances[sender] >= amount, "ASG:Insufficient balance");
        
        allowances[sender][msg.sender] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        success = true;
    }
    
    function burn(address spender, uint256 amount) internal returns (bool success) {
        require(amount > 0, "ASG: burn amount of ASG must be greater than 0");
        require(totalSupply > burnLimit, "ASG: Destruction up to limit");
        if (totalSupply - amount < burnLimit) {
            amount = totalSupply - burnLimit;
        }
        require(balances[spender] >= amount, "ASG: Insufficient balance");
        totalSupply -= amount;
        balances[spender] -= amount;
        balances[address(0)] += amount;
        emit Transfer(spender, address(0), amount);
        success = true;
    }
}