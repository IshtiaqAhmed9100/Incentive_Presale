// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IRounds {
    /// @notice Returns the round details of the round
    function rounds(uint32 round) external view returns (uint256 startTime, uint256 endTime, uint256 price);
}