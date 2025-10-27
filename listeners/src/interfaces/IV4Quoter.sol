// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IV4Quoter {
    // from https://github.com/Uniswap/v4-core/src/types/PoolKey.sol
    struct PoolKey {
        address currency0;
        address currency1;
        uint24 fee;
        int24 tickSpacing;
        address hooks;
    }
    struct QuoteExactSingleParams {
        PoolKey poolKey;
        bool zeroForOne;
        uint128 exactAmount;
        bytes hookData;
    }

    function quoteExactInputSingle(QuoteExactSingleParams memory params)
        external
        returns (uint256 amountOut, uint256 gasEstimate);
}