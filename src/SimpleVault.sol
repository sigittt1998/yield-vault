// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleVault is ERC4626, Ownable {
    using SafeERC20 for IERC20;

    uint256 public lastHarvest;
    uint256 public performanceFee = 1000; // 10% in basis points
    uint256 constant FEE_DENOMINATOR = 10000;
    address public feeRecipient;

    event Harvested(uint256 profit, uint256 fee, uint256 timestamp);
    event PerformanceFeeUpdated(uint256 oldFee, uint256 newFee);

    constructor(
        IERC20 asset_,
        string memory name_,
        string memory symbol_,
        address feeRecipient_
    ) ERC4626(asset_) ERC20(name_, symbol_) Ownable(msg.sender) {
        feeRecipient = feeRecipient_;
        lastHarvest = block.timestamp;
    }

    function harvest(uint256 profit) external onlyOwner {
        require(profit > 0, "nothing to harvest");

        IERC20 asset_ = IERC20(asset());
        asset_.safeTransferFrom(msg.sender, address(this), profit);

        uint256 fee = (profit * performanceFee) / FEE_DENOMINATOR;
        if (fee > 0 && feeRecipient != address(0)) {
            asset_.safeTransfer(feeRecipient, fee);
        }

        lastHarvest = block.timestamp;
        emit Harvested(profit, fee, block.timestamp);
    }

    function setPerformanceFee(uint256 newFee) external onlyOwner {
        require(newFee <= 2000, "fee too high"); // max 20%
        uint256 oldFee = performanceFee;
        performanceFee = newFee;
        emit PerformanceFeeUpdated(oldFee, newFee);
    }

    function setFeeRecipient(address newRecipient) external onlyOwner {
        require(newRecipient != address(0), "zero address");
        feeRecipient = newRecipient;
    }

    function timeSinceLastHarvest() external view returns (uint256) {
        return block.timestamp - lastHarvest;
    }
}
