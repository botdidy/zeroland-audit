// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/interfaces/IZeroLendPool.sol";
import "../src/interfaces/IERC20.sol";

contract LiquidationTest is Test {
    IZeroLendPool public pool;
    IERC20 public weth;
    IERC20 public usdc;
    address public constant POOL_ADDRESS = 0x0b5eB2C8D62F59D73488D8c8f567654FE6F0caF1;
    address public constant WETH_ADDRESS = 0xA219439258ca9da29E9Cc4cE5596924745e12B93;
    address public constant USDC_ADDRESS = 0x176211869cA2b568f2A7D4EE941E073a821EE1ff;

    function setUp() public {
        pool = IZeroLendPool(POOL_ADDRESS);
        weth = IERC20(WETH_ADDRESS);
        usdc = IERC20(USDC_ADDRESS);
    }

    function testLiquidationThreshold() public {
        address borrower = address(1);
        address liquidator = address(2);
        uint256 collateralAmount = 1 ether;
        uint256 borrowAmount = 1000e6; // 1000 USDC

        // Setup borrower's position
        deal(WETH_ADDRESS, borrower, collateralAmount);
        deal(USDC_ADDRESS, POOL_ADDRESS, borrowAmount * 2);

        vm.startPrank(borrower);
        weth.approve(POOL_ADDRESS, collateralAmount);
        pool.supply(WETH_ADDRESS, collateralAmount, borrower, 0);
        pool.borrow(USDC_ADDRESS, borrowAmount, 2, 0, borrower);
        vm.stopPrank();

        // Simulate price drop
        // This part depends on how the oracle is implemented in ZeroLend
        // For this test, we'll assume there's a function to update the price
        // updateAssetPrice(WETH_ADDRESS, 1000e8); // Assume 1 ETH = 1000 USD

        // Attempt liquidation
        vm.startPrank(liquidator);
        usdc.approve(POOL_ADDRESS, borrowAmount);
        
        uint256 debtToCover = borrowAmount / 2;
        pool.liquidationCall(WETH_ADDRESS, USDC_ADDRESS, borrower, debtToCover, false);

        // Check liquidation results
        uint256 liquidatorWethBalance = weth.balanceOf(liquidator);
        assertTrue(liquidatorWethBalance > 0, "Liquidator should receive collateral");

        vm.stopPrank();
    }
}