// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../src/interfaces/DataTypes.sol";
import "forge-std/Test.sol";
import "../src/interfaces/IZeroLendPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CollateralTest is Test {
    IZeroLendPool constant pool = IZeroLendPool(0x0b5eB2C8D62F59D73488D8c8f567654FE6F0caF1);
    
    address constant WETH = 0xA219439258ca9da29E9Cc4cE5596924745e12B93;
    address constant USDC = 0x176211869cA2b568f2A7D4EE941E073a821EE1ff;

    function setUp() public {
        vm.createSelectFork(vm.envString("LINEA_RPC_URL"));
    }

    function testCollateralWithdrawalLimit() public {
        address user = address(0x1);
        vm.startPrank(user);
        
        // Supply collateral
        deal(WETH, user, 10 ether);
        IERC20(WETH).approve(address(pool), 10 ether);
        pool.supply(WETH, 10 ether, user, 0);
        
        // Borrow against collateral
        uint256 borrowAmount = 5000e6; // 5000 USDC
        pool.borrow(USDC, borrowAmount, 2, 0, user);
        
        // Attempt to withdraw all collateral
        vm.expectRevert("The collateral balance is 0");
        pool.withdraw(WETH, type(uint256).max, user);
        
        // Attempt to withdraw maximum allowed
        (uint256 totalCollateralBase, uint256 totalDebtBase, uint256 availableBorrowsBase, , , ) = pool.getUserAccountData(user);
        uint256 maxWithdraw = totalCollateralBase - totalDebtBase + availableBorrowsBase;
        uint256 withdrawAmount = (maxWithdraw * 1e18) / pool.getPriceOracle().getAssetPrice(WETH);
        
        uint256 balanceBefore = IERC20(WETH).balanceOf(user);
        pool.withdraw(WETH, withdrawAmount, user);
        uint256 balanceAfter = IERC20(WETH).balanceOf(user);
        
        assertEq(balanceAfter - balanceBefore, withdrawAmount, "Should withdraw maximum allowed amount");
        
        vm.stopPrank();
    }
}