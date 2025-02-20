// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IZeroLendOracle {
    function getAssetPrice(address asset) external view returns (uint256);
}