// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/interfaces/IZeroLendPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidationTest is Test {
    IZeroLendPool constant pool = IZeroLendPool(0x0b5eB2C8D62F59D73488D8c8f567654FE6F0caF1);
    
    address constant WETH = 0xA219439258ca9da29E9Cc4cE5596924745e12B93;
    address constant USDC = 0x176211869cA2b568f2A7D4EE941E073a821EE1ff;

    function setUp() public {
        vm.createSelectFork(vm.envString("LINEA_RPC_URL"));
    }

    function testLiquidationThreshold() public {
        address user = address(0x1);
        vm.startPrank(user);
        
        // Supply collateral
        deal(WETH, user, 1 ether);
        IERC20(WETH).approve(address(pool), 1 ether);
        pool.supply(WETH, 1 ether, user, 0);
        
        // Borrow maximum amount
        uint256 borrowAmount = _getMaxBorrowAmount(user, USDC);
        pool.borrow(USDC, borrowAmount, 2, 0, user);
        
        vm.stopPrank();
        
        // Decrease collateral value
        vm.mockCall(
            address(pool.getPriceOracle()),
            abi.encodeWithSelector(IZeroLendOracle.getAssetPrice.selector, WETH),
            abi.encode(1000) // Significantly lower price
        );
        
        // Attempt liquidation
        vm.prank(address(0x2));
        pool.liquidationCall(WETH, USDC, user, type(uint256).max, false);
        
        // Check if liquidation was successful
        (uint256 totalCollateralBase, uint256 totalDebtBase, , , , ) = pool.getUserAccountData(user);
        assertLt(totalCollateralBase, totalDebtBase, "User should be liquidated");
    }

    function _getMaxBorrowAmount(address user, address asset) internal view returns (uint256) {
        (uint256 totalCollateralBase, uint256 totalDebtBase, uint256 availableBorrowsBase, , , ) = pool.getUserAccountData(user);
        uint256 assetPrice = pool.getPriceOracle().getAssetPrice(asset);
        return (availableBorrowsBase * 1e18) / assetPrice;
    }
}