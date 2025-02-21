// File: test/InterestRateTest.t.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/interfaces/IZeroLendPool.sol";
import "../src/interfaces/IReserveInterestRateStrategy.sol";
import "../src/interfaces/DataTypes.sol";

contract InterestRateTest is Test {
    IZeroLendPool public pool;
    address public constant POOL_ADDRESS = 0x0b5eB2C8D62F59D73488D8c8f567654FE6F0caF1;
    address public constant WETH_ADDRESS = 0xA219439258ca9da29E9Cc4cE5596924745e12B93;

    function setUp() public {
        pool = IZeroLendPool(POOL_ADDRESS);
    }

    function testExtremeUtilization() public {
        DataTypes.ReserveData memory reserveData = pool.getReserveData(WETH_ADDRESS);
        IReserveInterestRateStrategy strategy = IReserveInterestRateStrategy(reserveData.interestRateStrategyAddress);

        uint256 availableLiquidity = 1e15; // 0.001 WETH
        uint256 totalStableDebt = 0;
        uint256 totalVariableDebt = 1e18; // 1 WETH

        (uint256 liquidityRate, uint256 stableBorrowRate, uint256 variableBorrowRate) = strategy.calculateInterestRates(
            WETH_ADDRESS,
            availableLiquidity,
            totalStableDebt,
            totalVariableDebt,
            reserveData.averageStableBorrowRate,
            reserveData.reserveFactor,
            reserveData.currentLiquidityRate,
            reserveData.currentStableBorrowRate,
            reserveData.currentVariableBorrowRate
        );

        assertTrue(liquidityRate > 0, "Liquidity rate should be positive");
        assertTrue(stableBorrowRate > variableBorrowRate, "Stable borrow rate should be higher than variable borrow rate");
        assertTrue(variableBorrowRate > 0, "Variable borrow rate should be positive");
    }
}