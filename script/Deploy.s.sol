// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {SimpleVault} from "../src/SimpleVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Deploy is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address asset = vm.envAddress("ASSET_ADDRESS");
        address feeRecipient = vm.envAddress("FEE_RECIPIENT");

        vm.startBroadcast(pk);
        new SimpleVault(
            IERC20(asset),
            "Yield Vault",
            "yVLT",
            feeRecipient
        );
        vm.stopBroadcast();
    }
}
