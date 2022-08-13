pragma solidity ^0.4.24;

contract IUniswapV2Router02 {

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}
