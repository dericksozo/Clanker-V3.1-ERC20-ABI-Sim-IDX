// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "sim-idx-generated/Generated.sol";
import "./interfaces/IClankerTokenV3_1.sol";

contract ClankerTokenListener is ERC20$OnTransferEvent {
    // --- Known core addresses (Base) ---
    // address constant CLANKER_V4_0_0_BASE         = 0xE85A59c628F7d27878ACeB4bf3b35733630083a9;
    // address constant CLANKER_V3_1_FACTORY_BASE   = 0x2A787b2362021cC3eEa3C24C4748a6cD5B687382;

    address constant CLANKER_V3_1_FACTORY_BASE = 0x2A787b2362021cC3eEa3C24C4748a6cD5B687382;
    address constant CLANKER_V4_FACTORY_BASE = 0xE85A59c628F7d27878ACeB4bf3b35733630083a9;

    struct TransferData {
        address fromAddress;
        address toAddress;
        address token;
        uint256 value;
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

    function onTransferEvent(
        EventContext memory ctx,
        ERC20$TransferEventParams memory inputs
    ) external override {

        address deployedContract = ctx.sim.getDeployer(ctx.txn.call.callee());

        if (deployedContract == CLANKER_V4_FACTORY_BASE) {

            string memory tokenContext = IClankerTokenV3_1(ctx.txn.call.callee()).context();
            bool isRetakeToken = containsStreammDeployment(tokenContext);
            
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
                factoryVersion: "4",
                contractDeployerAddress: deployedContract,
                isRetakeToken: isRetakeToken
            });
            
            emit Transfer(data);

        } else if (deployedContract == CLANKER_V3_1_FACTORY_BASE) {

            string memory tokenContext = IClankerTokenV3_1(ctx.txn.call.callee()).context();
            bool isRetakeToken = containsStreammDeployment(tokenContext);

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
                factoryVersion: "3.1",
                contractDeployerAddress: deployedContract,
                isRetakeToken: isRetakeToken
            });
            
            emit Transfer(data);

        }
    }

    // ---------- helpers ----------
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