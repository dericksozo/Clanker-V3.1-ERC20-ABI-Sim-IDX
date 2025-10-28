// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "sim-idx-generated/Generated.sol";
import "./interfaces/IClankerTokenV3_1.sol";
import "./interfaces/IV4Quoter.sol";
import "./interfaces/IV3QuoterV2.sol";
import "./interfaces/IClankerV4_0.sol";
import "./interfaces/IClankerTokenV4_0.sol";

// ---- Minimal Uniswap v3 interfaces needed for pool discovery / checks ----
interface IUniswapV3Factory {
    function getPool(address tokenA, address tokenB, uint24 fee) external view returns (address);
}
interface IUniswapV3Pool {
    function liquidity() external view returns (uint128);
}
// Local QuoterV2 interface with struct signature (per Uniswap v3 Periphery)
interface IQuoterV2 {
    struct QuoteExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint24  fee;
        uint160 sqrtPriceLimitX96;
    }
    function quoteExactInputSingle(QuoteExactInputSingleParams calldata params)
        external
        returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32  initializedTicksCrossed,
            uint256 gasEstimate
        );

    function quoteExactInput(bytes calldata path, uint256 amountIn)
        external
        returns (
            uint256 amountOut,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[]  memory initializedTicksCrossedList,
            uint256 gasEstimate
        );
}

contract ClankerTokenListener is ERC20$OnTransferEvent {
    // --- Known core addresses (Base) ---
    // address constant CLANKER_V4_0_0_BASE         = 0xE85A59c628F7d27878ACeB4bf3b35733630083a9;
    // address constant CLANKER_V3_1_FACTORY_BASE   = 0x2A787b2362021cC3eEa3C24C4748a6cD5B687382;

    // Clanker Token Factory Addresses
    address constant CLANKER_V3_1_FACTORY_BASE = 0x2A787b2362021cC3eEa3C24C4748a6cD5B687382;
    address constant CLANKER_V4_FACTORY_BASE   = 0xE85A59c628F7d27878ACeB4bf3b35733630083a9;

    // Uniswap v3/v4 + core tokens on Base
    address constant WETH_BASE              = 0x4200000000000000000000000000000000000006;
    address constant UNISWAP_V4_QUOTER_BASE = 0x0d5e0F971ED27FBfF6c2837bf31316121532048D;
    address constant UNISWAP_V3_QUOTER_BASE = 0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a; // QuoterV2
    IUniswapV3Factory constant UNISWAP_V3_FACTORY_BASE = IUniswapV3Factory(0x33128a8fC17869897dcE68Ed026d694621f6FDfD);
    address constant USDC_BASE              = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    // Common v3 fee tiers
    uint24 constant FEE_1bps   = 100;     // 0.01%
    uint24 constant FEE_5bps   = 500;     // 0.05%
    uint24 constant FEE_30bps  = 3000;    // 0.30%
    uint24 constant FEE_100bps = 10000;   // 1.00%

    uint256 constant MINIMUM_ETH_VALUE = 0.001 ether;
    uint24  public constant DYNAMIC_FEE_FLAG = 0x800000; // Uniswap v4 dynamic fee flag

    struct TransferData {
        address fromAddress;
        address toAddress;
        address token;
        uint256 value;
        uint256 ethValueInWei;
        bytes32 txHash;
        string  tokenContext;
        uint256 blockNumber;
        uint256 blockTimestamp;
        bool    sell;
        string  factoryVersion;
        address contractDeployerAddress;
        bool    isRetakeToken;
    }

    event Transfer(TransferData);
    event QuoterError(string reason);
    event QuoterLowLevelError(bytes lowLevelData);
    event V3QuoterError(string reason);
    event V3QuoterLowLevelError(bytes lowLevelData);

    function onTransferEvent(
        EventContext memory ctx,
        ERC20$TransferEventParams memory inputs
    ) external override {

        address deployedContract = ctx.sim.getDeployer(ctx.txn.call.callee());

        string memory factoryVersion;
        if (deployedContract == CLANKER_V4_FACTORY_BASE) {
            factoryVersion = "4";
        } else if (deployedContract == CLANKER_V3_1_FACTORY_BASE) {
            factoryVersion = "3.1";
        } else {
            return;
        }

        string memory tokenContext;
        try IClankerTokenV3_1(ctx.txn.call.callee()).context() returns (string memory _context) {
            tokenContext = _context;
        } catch {
            return;
        }
        bool isRetakeToken = containsStreammDeployment(tokenContext);

        if (!isRetakeToken) {
            return;
        }

        uint256 ethValueInWei;

        if (deployedContract == CLANKER_V4_FACTORY_BASE) {
            ethValueInWei = getValueInEthV4(
                ctx.txn.call.callee(),
                ctx.txn.hash(),
                inputs.value
            );
        } else if (deployedContract == CLANKER_V3_1_FACTORY_BASE) {
            ethValueInWei = getValueInEthV31(
                ctx.txn.call.callee(),
                ctx.txn.hash(),
                inputs.value
            );
        }

        // if (ethValueInWei < MINIMUM_ETH_VALUE) {
        //  return;
        // }

        TransferData memory data = TransferData({
            fromAddress: inputs.from,
            toAddress: inputs.to,
            token: ctx.txn.call.callee(),
            value: inputs.value,
            txHash: ctx.txn.hash(),
            tokenContext: tokenContext,
            blockNumber: block.number,
            blockTimestamp: block.timestamp,
            sell: ctx.txn.call.caller() == inputs.from,
            factoryVersion: factoryVersion,
            contractDeployerAddress: deployedContract,
            isRetakeToken: isRetakeToken,
            ethValueInWei: ethValueInWei
        });

        emit Transfer(data);
    }

    // ---------- helpers ----------

    function getValueInEthV4(
        address token,
        bytes32 txHash,
        uint256 amount
    ) internal returns (uint256) {
        IClankerV4_0 clanker = IClankerV4_0(CLANKER_V4_FACTORY_BASE);

        IClankerV4_0.DeploymentInfo memory deploymentInfo = clanker
            .tokenDeploymentInfo(token);

        (address c0, address c1, bool aIsFirst) = addressSort(token, WETH_BASE);

        // generate poolId
        IV4Quoter.PoolKey memory poolKey = IV4Quoter.PoolKey({
            currency0: token < WETH_BASE ? token : WETH_BASE,
            currency1: token < WETH_BASE ? WETH_BASE : token,
            fee: DYNAMIC_FEE_FLAG,
            tickSpacing: 200,
            hooks: deploymentInfo.hook
        });

        // Generate the poolId as the keccak256 hash of the encoded poolKey
        bytes32 poolId = keccak256(abi.encode(poolKey));

        // Check for overflow when converting uint256 to uint128
        require(amount <= type(uint128).max, "Amount too large for uint128");

        IV4Quoter.QuoteExactSingleParams
            memory quoteExactSingleParams = IV4Quoter.QuoteExactSingleParams({
                poolKey: poolKey,
                zeroForOne: token < WETH_BASE,
                exactAmount: uint128(amount),
                hookData: '0x00'
            });

        IV4Quoter quoter = IV4Quoter(UNISWAP_V4_QUOTER_BASE);

        try quoter.quoteExactInputSingle(quoteExactSingleParams) returns (uint256 amountOut, uint256 gasEstimate) {
            return amountOut;
        } catch Error(string memory reason) {
            // Handle string errors (e.g., "Pool not found", "Insufficient liquidity")
            emit QuoterError(reason);
            return 0;
        } catch (bytes memory lowLevelData) {
            // Handle low-level errors (e.g., function not found, revert without reason)
            emit QuoterLowLevelError(lowLevelData);
            return 0;
        }
    }

    // -------- v3.1 pricing (updated) --------

    /// Find an existing, initialized v3 pool for (token, WETH). Prefers 1% first, then common tiers.
    function _findInitializedV3Pool(address token) internal view returns (address pool, uint24 fee) {
        uint24[4] memory fees = [FEE_100bps, FEE_30bps, FEE_5bps, FEE_1bps];
        for (uint256 i = 0; i < fees.length; ++i) {
            address p = UNISWAP_V3_FACTORY_BASE.getPool(token, WETH_BASE, fees[i]);
            if (p != address(0) && IUniswapV3Pool(p).liquidity() > 0) {
                return (p, fees[i]);
            }
        }
        return (address(0), 0);
    }

    /// Single-hop quote using QuoterV2 struct params on the discovered fee tier.
    function _quoteV3SingleHop(address token, uint24 fee, uint256 amountIn) internal returns (uint256) {
        if (fee == 0) return 0;
        IQuoterV2 quoter = IQuoterV2(UNISWAP_V3_QUOTER_BASE);
        try quoter.quoteExactInputSingle(
            IQuoterV2.QuoteExactInputSingleParams({
                tokenIn: token,
                tokenOut: WETH_BASE,
                amountIn: amountIn,
                fee: fee,
                sqrtPriceLimitX96: 0
            })
        ) returns (
            uint256 amountOut,
            uint160 /* sqrtPriceX96After */,
            uint32  /* initializedTicksCrossed */,
            uint256 /* gasEstimate */
        ) {
            return amountOut;
        } catch {
            return 0;
        }
    }

    /// Multi-hop quote token->USDC->WETH with realistic fee combos.
    function _quoteV3ViaUSDC(address token, uint256 amountIn) internal returns (uint256) {
        IQuoterV2 quoter = IQuoterV2(UNISWAP_V3_QUOTER_BASE);
        uint24[2] memory leg1Fees = [FEE_100bps, FEE_30bps]; // token->USDC
        uint24[2] memory leg2Fees = [FEE_5bps,   FEE_30bps]; // USDC->WETH
        for (uint256 i = 0; i < leg1Fees.length; ++i) {
            for (uint256 j = 0; j < leg2Fees.length; ++j) {
                bytes memory path = abi.encodePacked(token, leg1Fees[i], USDC_BASE, leg2Fees[j], WETH_BASE);
                try quoter.quoteExactInput(path, amountIn)
                returns (
                    uint256 amountOut,
                    uint160[] memory /* sqrtPriceX96AfterList */,
                    uint32[]  memory /* initializedTicksCrossedList */,
                    uint256 /* gasEstimate */
                ) {
                    if (amountOut > 0) return amountOut;
                } catch { /* continue */ }
            }
        }
        return 0;
    }

    function getValueInEthV31(
        address token,
        bytes32 txHash,
        uint256 amount
    ) internal returns (uint256) {
        // 1) Find the actual CLANKER/WETH pool + fee on Base and ensure it's initialized.
        (address pool, uint24 discoveredFee) = _findInitializedV3Pool(token);

        // 2) If live pool exists, try single-hop on that fee tier.
        if (pool != address(0)) {
            uint256 outSingle = _quoteV3SingleHop(token, discoveredFee, amount);
            if (outSingle > 0) return outSingle;
        }

        // 3) Fallback: try multi-hop via USDC with realistic fee combinations.
        uint256 outMulti = _quoteV3ViaUSDC(token, amount);
        if (outMulti > 0) return outMulti;

        // 4) No route
        return 0;
    }

    function addressSort(
        address a,
        address b
    ) internal pure returns (address, address, bool aIsFirst) {
        if (uint160(a) < uint160(b)) return (a, b, true);
        return (b, a, false);
    }

    function containsStreammDeployment(string memory tokenContext) internal pure returns (bool) {
        bytes memory contextBytes = bytes(tokenContext);
        bytes memory pattern = bytes("streamm deployment");
        if (contextBytes.length < pattern.length) return false;
        for (uint i = 0; i <= contextBytes.length - pattern.length; i++) {
            bool found = true;
            for (uint j = 0; j < pattern.length; j++) {
                if (contextBytes[i + j] != pattern[j]) { found = false; break; }
            }
            if (found) return true;
        }
        return false;
    }
}