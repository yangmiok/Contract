//SPDX-License-Identifier:MIT
pragma solidity 0.8.6;

interface ISunswapV2Router02 {
    function swapExactTokensForTokens(
        uint256 amountIn, 
        uint256 amountOutMin, 
        address[] memory path_address, 
        address to_address, 
        uint256 deadline_uint256
    ) external returns (uint256, uint256);
}