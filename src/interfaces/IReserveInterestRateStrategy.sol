// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

interface IReserveInterestRateStrategy {
    function calculateInterestRates(
        address reserve,
        uint256 availableLiquidity,
        uint256 totalStableDebt,
        uint256 totalVariableDebt,
        uint256 averageStableBorrowRate,
        uint256 reserveFactor,
        uint256 currentLiquidityRate,
        uint256 currentStableBorrowRate,
        uint256 currentVariableBorrowRate
    ) external view returns (uint256, uint256, uint256);
}