// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

interface IZeroLendOracle {
    function getAssetPrice(address asset) external view returns (uint256);
}