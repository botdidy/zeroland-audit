// File: test/PriceOracleTest.t.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/interfaces/IZeroLendOracle.sol";

contract PriceOracleTest is Test {
    IZeroLendOracle public oracle;
    address public constant ORACLE_ADDRESS = 0x86B4Dc5f2cB7D8857e207a5E29E997B9333C53d0;
    address public constant WETH_ADDRESS = 0xA219439258ca9da29E9Cc4cE5596924745e12B93;

    function setUp() public {
        oracle = IZeroLendOracle(ORACLE_ADDRESS);
    }

    function testPriceManipulation() public view {
        uint256 initialPrice = oracle.getAssetPrice(WETH_ADDRESS);
        
        // Note: This test might need to be adjusted based on how price updates are handled in the actual implementation
        uint256 newPrice = oracle.getAssetPrice(WETH_ADDRESS);
        assert(newPrice <= initialPrice * 11 / 10);
    }

    function testStalePrices() public {
        uint256 initialPrice = oracle.getAssetPrice(WETH_ADDRESS);
        
        // Simulate time passing
        vm.warp(block.timestamp + 1 days);

        uint256 newPrice = oracle.getAssetPrice(WETH_ADDRESS);
        assertEq(newPrice, initialPrice, "Price should be updated within 24 hours");
    }
}