# yield-vault

Simple ERC-4626 auto-compounding vault built with Foundry.

Deposit an ERC-20 token, owner runs a strategy off-chain and calls `harvest()` to add profits back to the vault. Share value goes up automatically for all depositors.

## How it works

1. Users deposit tokens → receive vault shares
2. Owner runs yield strategy externally (lending, LP, whatever)
3. Owner calls `harvest(profit)` → profit distributed to all shareholders proportionally
4. 10% performance fee goes to fee recipient

## Build

```bash
forge install OpenZeppelin/openzeppelin-contracts
forge build
```

## Test

```bash
forge test -vvv
```

## Deploy

```bash
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast
```

## Config

- `performanceFee`: default 10% (1000 bps), max 20%
- `feeRecipient`: address that receives performance fees
- Both configurable by owner

## Security

This is unaudited code. Use at your own risk. Not intended for production use with significant funds.
