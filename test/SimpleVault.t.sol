// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {SimpleVault} from "../src/SimpleVault.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract SimpleVaultTest is Test {
    SimpleVault vault;
    ERC20Mock token;
    address owner = address(this);
    address user = address(0xBEEF);
    address feeRecipient = address(0xFEE);

    function setUp() public {
        token = new ERC20Mock();
        vault = new SimpleVault(token, "Vault Token", "vTKN", feeRecipient);

        token.mint(owner, 100_000e18);
        token.mint(user, 10_000e18);

        token.approve(address(vault), type(uint256).max);
        vm.prank(user);
        token.approve(address(vault), type(uint256).max);
    }

    function test_deposit() public {
        vm.prank(user);
        vault.deposit(1000e18, user);

        assertEq(vault.balanceOf(user), 1000e18);
        assertEq(token.balanceOf(address(vault)), 1000e18);
    }

    function test_withdraw() public {
        vm.prank(user);
        vault.deposit(1000e18, user);

        vm.prank(user);
        vault.withdraw(500e18, user, user);

        assertEq(vault.balanceOf(user), 500e18);
    }

    function test_harvest() public {
        vm.prank(user);
        vault.deposit(1000e18, user);

        // simulate profit
        vault.harvest(100e18);

        uint256 fee = (100e18 * 1000) / 10000; // 10%
        assertEq(token.balanceOf(feeRecipient), fee);
    }

    function test_harvest_increases_share_value() public {
        vm.prank(user);
        vault.deposit(1000e18, user);

        vault.harvest(100e18);

        // share value should be higher now
        uint256 assets = vault.convertToAssets(1000e18);
        assertGt(assets, 1000e18);
    }

    function test_fee_cap() public {
        vm.expectRevert("fee too high");
        vault.setPerformanceFee(2001);
    }

    function test_only_owner_harvest() public {
        vm.prank(user);
        vm.expectRevert();
        vault.harvest(100e18);
    }
}
