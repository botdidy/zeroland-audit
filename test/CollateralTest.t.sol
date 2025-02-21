// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/interfaces/IZeroLendPool.sol";
import "../src/interfaces/IERC20.sol";

contract CollateralTest is Test {
    IZeroLendPool public pool;
    IERC20 public weth;
    address public constant POOL_ADDRESS = 0x0b5eB2C8D62F59D73488D8c8f567654FE6F0caF1;
    address public constant WETH_ADDRESS = 0xA219439258ca9da29E9Cc4cE5596924745e12B93;

    function setUp() public {
        pool = IZeroLendPool(POOL_ADDRESS);
        weth = IERC20(WETH_ADDRESS);
    }

    function testCollateralWithdrawalLimit() public {
        address user = address(1);
        uint256 depositAmount = 10 ether;

        // Mint WETH to the user
        deal(WETH_ADDRESS, user, depositAmount);

        vm.startPrank(user);

        // Approve and supply WETH as collateral
        weth.approve(POOL_ADDRESS, depositAmount);
        pool.supply(WETH_ADDRESS, depositAmount, user, 0);

        // Try to withdraw more than deposited
        uint256 withdrawAmount = depositAmount + 1 ether;
        vm.expectRevert();
        pool.withdraw(WETH_ADDRESS, withdrawAmount, user);

        // Withdraw the exact amount deposited
        uint256 withdrawnAmount = pool.withdraw(WETH_ADDRESS, depositAmount, user);
        assertEq(withdrawnAmount, depositAmount, "Should withdraw the full deposited amount");

        vm.stopPrank();
    }
}