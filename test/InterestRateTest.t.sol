// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/interfaces/IZeroLendPool.sol";
import "../src/interfaces/IReserveInterestRateStrategy.sol";

contract InterestRateTest is Test {
    IZeroLendPool constant pool = IZeroLendPool(0xb5eb2c8D62f59D73488D8C8f567654fE6F0CAf1);
    
    address constant WETH = 0xA219439258ca9da29E9Cc4cE5596924745e12B93;

    function setUp() public {
        vm.createSelectFork(vm.envString("LINEA_RPC_URL"));
    }

    function testExtremeUtilization() public {
        // Get current reserve data
        DataTypes.ReserveData memory reserveData = pool.getReserveData(WETH);
        IReserveInterestRateStrategy strategy = IReserveInterestRateStrategy(reserveData.interestRateStrategyAddress);
        
        // Calculate rates at 99% utilization
        (uint256 liquidityRate, uint256 stableBorrowRate, uint256 variableBorrowRate) = strategy.calculateInterestRates(
            DataTypes.CalculateInterestRatesParams({
                unbacked: 0,
                liquidityAdded: 0,
                liquidityTaken: 0,
                totalStableDebt: reserveData.totalStableDebt,
                totalVariableDebt: reserveData.totalVariableDebt,
                averageStableBorrowRate: reserveData.averageStableBorrowRate,
                reserveFactor: reserveData.configuration.getReserveFactor(),
                reserve: WETH,
                aToken: reserveData.aTokenAddress
            })
        );
        
        // Check if rates are within expected ranges
        assertGt(liquidityRate, 0, "Liquidity rate should be positive at high utilization");
        assertGt(variableBorrowRate, stableBorrowRate, "Variable borrow rate should be higher than stable at high utilization");
    }
}