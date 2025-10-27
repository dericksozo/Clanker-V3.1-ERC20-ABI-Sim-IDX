// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IV3QuoterV2 {
    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (
        uint256 amountOut,
        uint160 sqrtPriceX96After,
        uint32 initializedTicksCrossed,
        uint256 gasEstimate
    );

	function quoteExactInput(
		bytes memory path,
		uint256 amountIn
	) external returns (
		uint256 amountOut,
		uint160[] memory sqrtPriceX96AfterList,
		uint32[] memory initializedTicksCrossedList,
		uint256 gasEstimate
	);
}


