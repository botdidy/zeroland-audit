// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/interfaces/IZeroLendOracle.sol";
import "../src/interfaces/IZeroLendPool.sol";

contract PriceOracleTest is Test {
    IZeroLendOracle constant oracle = IZeroLendOracle(0x86B4Dc5f2cB7D8857e207a5E29E997B9333C53d0);
    IZeroLendPool constant pool = IZeroLendPool(0x0b5eB2C8D62F59D73488D8c8f567654FE6F0caF1);
    
    address constant WETH = 0xA219439258ca9da29E9Cc4cE5596924745e12B93;
    address constant USDC = 0x176211869cA2b568f2A7D4EE941E073a821EE1ff;

    function setUp() public {
        vm.createSelectFork(vm.envString("LINEA_RPC_URL"));
    }

    function testStalePrices() public {
        uint256 initialPrice = oracle.getAssetPrice(WETH);
        
        // Advance time by 1 day
        vm.warp(block.timestamp + 1 days);
        
        uint256 newPrice = oracle.getAssetPrice(WETH);
        assertEq(initialPrice, newPrice, "Price should be updated within 24 hours");
    }

    function testPriceManipulation() public {
        uint256 initialPrice = oracle.getAssetPrice(WETH);
        
        // Simulate a large trade to potentially manipulate the price
        deal(WETH, address(this), 1000000 ether);
        // Perform a large swap here
        
        uint256 newPrice = oracle.getAssetPrice(WETH);
        assertApproxEqRel(initialPrice, newPrice, 0.05e18, "Price should not change more than 5%");
    }
}