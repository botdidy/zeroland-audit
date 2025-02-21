// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/interfaces/IZeroLendPool.sol";
import "../src/interfaces/IERC20.sol";

contract FlashLoanTest is Test {
    IZeroLendPool public pool;
    IERC20 public weth;
    address public constant POOL_ADDRESS = 0x0b5eB2C8D62F59D73488D8c8f567654FE6F0caF1;
    address public constant WETH_ADDRESS = 0xA219439258ca9da29E9Cc4cE5596924745e12B93;

    function setUp() public {
        pool = IZeroLendPool(POOL_ADDRESS);
        weth = IERC20(WETH_ADDRESS);
    }

    function testFlashLoanReentrancy() public {
        address attacker = address(this);
        uint256 flashLoanAmount = 100 ether;

        // Prepare the flash loan parameters
        address[] memory assets = new address[](1);
        assets[0] = WETH_ADDRESS;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = flashLoanAmount;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0; // 0 = no debt, 1 = stable, 2 = variable

        // Expect revert due to reentrancy guard
        vm.expectRevert("ReentrancyGuard: reentrant call");
        pool.flashLoan(
            attacker,
            assets,
            amounts,
            modes,
            attacker,
            "",
            0
        );
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        // Attempt reentrancy
        address[] memory reentryAssets = new address[](1);
        reentryAssets[0] = assets[0];

        uint256[] memory reentryAmounts = new uint256[](1);
        reentryAmounts[0] = amounts[0] / 2;

        uint256[] memory reentryModes = new uint256[](1);
        reentryModes[0] = 0;

        pool.flashLoan(
            address(this),
            reentryAssets,
            reentryAmounts,
            reentryModes,
            address(this),
            "",
            0
        );

        // Approve repayment
        IERC20(assets[0]).approve(address(pool), amounts[0] + premiums[0]);

        return true;
    }
}