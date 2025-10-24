// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/sim-idx-sol/src/Triggers.sol";
import "lib/sim-idx-sol/src/Context.sol";

function ERC20$Abi() pure returns (Abi memory) {
    return Abi("ERC20");
}
struct ERC20$AllowanceFunctionInputs {
    address _owner;
    address _spender;
}

struct ERC20$AllowanceFunctionOutputs {
    uint256 outArg0;
}

struct ERC20$ApproveFunctionInputs {
    address _spender;
    uint256 _value;
}

struct ERC20$ApproveFunctionOutputs {
    bool outArg0;
}

struct ERC20$BalanceOfFunctionInputs {
    address _owner;
}

struct ERC20$BalanceOfFunctionOutputs {
    uint256 balance;
}

struct ERC20$DecimalsFunctionOutputs {
    uint8 outArg0;
}

struct ERC20$NameFunctionOutputs {
    string outArg0;
}

struct ERC20$SymbolFunctionOutputs {
    string outArg0;
}

struct ERC20$TotalSupplyFunctionOutputs {
    uint256 outArg0;
}

struct ERC20$TransferFunctionInputs {
    address _to;
    uint256 _value;
}

struct ERC20$TransferFunctionOutputs {
    bool outArg0;
}

struct ERC20$TransferFromFunctionInputs {
    address _from;
    address _to;
    uint256 _value;
}

struct ERC20$TransferFromFunctionOutputs {
    bool outArg0;
}

struct ERC20$ApprovalEventParams {
    address owner;
    address spender;
    uint256 value;
}

struct ERC20$TransferEventParams {
    address from;
    address to;
    uint256 value;
}

abstract contract ERC20$OnApprovalEvent {
    function onApprovalEvent(EventContext memory ctx, ERC20$ApprovalEventParams memory inputs) virtual external;

    function triggerOnApprovalEvent() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes32(0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925),
            triggerType: TriggerType.EVENT,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onApprovalEvent.selector
        });
    }
}

abstract contract ERC20$OnTransferEvent {
    function onTransferEvent(EventContext memory ctx, ERC20$TransferEventParams memory inputs) virtual external;

    function triggerOnTransferEvent() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes32(0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef),
            triggerType: TriggerType.EVENT,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onTransferEvent.selector
        });
    }
}

abstract contract ERC20$OnAllowanceFunction {
    function onAllowanceFunction(FunctionContext memory ctx, ERC20$AllowanceFunctionInputs memory inputs, ERC20$AllowanceFunctionOutputs memory outputs) virtual external;

    function triggerOnAllowanceFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0xdd62ed3e),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onAllowanceFunction.selector
        });
    }
}

abstract contract ERC20$PreAllowanceFunction {
    function preAllowanceFunction(PreFunctionContext memory ctx, ERC20$AllowanceFunctionInputs memory inputs) virtual external;

    function triggerPreAllowanceFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0xdd62ed3e),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preAllowanceFunction.selector
        });
    }
}

abstract contract ERC20$OnApproveFunction {
    function onApproveFunction(FunctionContext memory ctx, ERC20$ApproveFunctionInputs memory inputs, ERC20$ApproveFunctionOutputs memory outputs) virtual external;

    function triggerOnApproveFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x095ea7b3),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onApproveFunction.selector
        });
    }
}

abstract contract ERC20$PreApproveFunction {
    function preApproveFunction(PreFunctionContext memory ctx, ERC20$ApproveFunctionInputs memory inputs) virtual external;

    function triggerPreApproveFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x095ea7b3),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preApproveFunction.selector
        });
    }
}

abstract contract ERC20$OnBalanceOfFunction {
    function onBalanceOfFunction(FunctionContext memory ctx, ERC20$BalanceOfFunctionInputs memory inputs, ERC20$BalanceOfFunctionOutputs memory outputs) virtual external;

    function triggerOnBalanceOfFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x70a08231),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onBalanceOfFunction.selector
        });
    }
}

abstract contract ERC20$PreBalanceOfFunction {
    function preBalanceOfFunction(PreFunctionContext memory ctx, ERC20$BalanceOfFunctionInputs memory inputs) virtual external;

    function triggerPreBalanceOfFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x70a08231),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preBalanceOfFunction.selector
        });
    }
}

abstract contract ERC20$OnDecimalsFunction {
    function onDecimalsFunction(FunctionContext memory ctx, ERC20$DecimalsFunctionOutputs memory outputs) virtual external;

    function triggerOnDecimalsFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x313ce567),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onDecimalsFunction.selector
        });
    }
}

abstract contract ERC20$PreDecimalsFunction {
    function preDecimalsFunction(PreFunctionContext memory ctx) virtual external;

    function triggerPreDecimalsFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x313ce567),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preDecimalsFunction.selector
        });
    }
}

abstract contract ERC20$OnNameFunction {
    function onNameFunction(FunctionContext memory ctx, ERC20$NameFunctionOutputs memory outputs) virtual external;

    function triggerOnNameFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x06fdde03),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onNameFunction.selector
        });
    }
}

abstract contract ERC20$PreNameFunction {
    function preNameFunction(PreFunctionContext memory ctx) virtual external;

    function triggerPreNameFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x06fdde03),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preNameFunction.selector
        });
    }
}

abstract contract ERC20$OnSymbolFunction {
    function onSymbolFunction(FunctionContext memory ctx, ERC20$SymbolFunctionOutputs memory outputs) virtual external;

    function triggerOnSymbolFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x95d89b41),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onSymbolFunction.selector
        });
    }
}

abstract contract ERC20$PreSymbolFunction {
    function preSymbolFunction(PreFunctionContext memory ctx) virtual external;

    function triggerPreSymbolFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x95d89b41),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preSymbolFunction.selector
        });
    }
}

abstract contract ERC20$OnTotalSupplyFunction {
    function onTotalSupplyFunction(FunctionContext memory ctx, ERC20$TotalSupplyFunctionOutputs memory outputs) virtual external;

    function triggerOnTotalSupplyFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x18160ddd),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onTotalSupplyFunction.selector
        });
    }
}

abstract contract ERC20$PreTotalSupplyFunction {
    function preTotalSupplyFunction(PreFunctionContext memory ctx) virtual external;

    function triggerPreTotalSupplyFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x18160ddd),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preTotalSupplyFunction.selector
        });
    }
}

abstract contract ERC20$OnTransferFunction {
    function onTransferFunction(FunctionContext memory ctx, ERC20$TransferFunctionInputs memory inputs, ERC20$TransferFunctionOutputs memory outputs) virtual external;

    function triggerOnTransferFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0xa9059cbb),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onTransferFunction.selector
        });
    }
}

abstract contract ERC20$PreTransferFunction {
    function preTransferFunction(PreFunctionContext memory ctx, ERC20$TransferFunctionInputs memory inputs) virtual external;

    function triggerPreTransferFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0xa9059cbb),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preTransferFunction.selector
        });
    }
}

abstract contract ERC20$OnTransferFromFunction {
    function onTransferFromFunction(FunctionContext memory ctx, ERC20$TransferFromFunctionInputs memory inputs, ERC20$TransferFromFunctionOutputs memory outputs) virtual external;

    function triggerOnTransferFromFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x23b872dd),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onTransferFromFunction.selector
        });
    }
}

abstract contract ERC20$PreTransferFromFunction {
    function preTransferFromFunction(PreFunctionContext memory ctx, ERC20$TransferFromFunctionInputs memory inputs) virtual external;

    function triggerPreTransferFromFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes4(0x23b872dd),
            triggerType: TriggerType.PRE_FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.preTransferFromFunction.selector
        });
    }
}


struct ERC20$EmitAllEvents$Approval {
  address owner;
  address spender;
  uint256 value;
}

struct ERC20$EmitAllEvents$Transfer {
  address from;
  address to;
  uint256 value;
}

contract ERC20$EmitAllEvents is
  ERC20$OnApprovalEvent,
ERC20$OnTransferEvent
{
  event Approval(ERC20$EmitAllEvents$Approval);
  event Transfer(ERC20$EmitAllEvents$Transfer);

  function onApprovalEvent(EventContext memory ctx, ERC20$ApprovalEventParams memory inputs) virtual external override {
    emit Approval(ERC20$EmitAllEvents$Approval(inputs.owner, inputs.spender, inputs.value));
  }
function onTransferEvent(EventContext memory ctx, ERC20$TransferEventParams memory inputs) virtual external override {
    emit Transfer(ERC20$EmitAllEvents$Transfer(inputs.from, inputs.to, inputs.value));
  }

  function allTriggers() view external returns (Trigger[] memory) {
    Trigger[] memory triggers = new Trigger[](2);
    triggers[0] = this.triggerOnApprovalEvent();
    triggers[1] = this.triggerOnTransferEvent();
    return triggers;
  }
}