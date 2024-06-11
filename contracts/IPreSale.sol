// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IRounds } from "./IRounds.sol";

interface IPreSale is IRounds {
    /// @notice Purchases token with claim amount
    /// @param token The purchase token
    /// @param tokenPrice The current price of token in 10 decimals
    /// @param referenceNormalizationFactor The value to handle decimals
    /// @param amount The purchase amount
    /// @param minAmountToken The minimum amount of token recipient will get
    /// @param recipient The address of the recipient
    /// @param round The round in which user will purchase
    function purchaseWithClaim(
        IERC20 token,
        uint256 tokenPrice,
        uint8 referenceNormalizationFactor,
        uint256 amount,
        uint256 minAmountToken,
        address recipient,
        uint32 round
    ) external payable;
}