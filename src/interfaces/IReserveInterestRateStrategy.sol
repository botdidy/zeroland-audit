// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./DataTypes.sol";

interface IReserveInterestRateStrategy {
    function calculateInterestRates(DataTypes.CalculateInterestRatesParams memory params)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );
}