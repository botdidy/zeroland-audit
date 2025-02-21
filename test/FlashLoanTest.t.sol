// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../src/interfaces/DataTypes.sol";
import "forge-std/Test.sol";
import "../src/interfaces/IZeroLendPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashLoanTest is Test {
    IZeroLendPool constant pool = IZeroLendPool(0x0b5eB2C8D62F59D73488D8c8f567654FE6F0caF1);
    
    address constant WETH = 0xA219439258ca9da29E9Cc4cE5596924745e12B93;
    address constant USDC = 0x176211869cA2b568f2A7D4EE941E073a821EE1ff;

    function setUp() public {
        vm.createSelectFork(vm.envString("LINEA_RPC_URL"));
    }

    function testFlashLoanReentrancy() public {
        address[] memory assets = new address[](1);
        assets[0] = WETH;
        
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100 ether;
        
        bytes memory params = abi.encode(WETH, 100 ether);
        
        vm.expectRevert("ReentrancyGuard: reentrant call");
        pool.flashLoan(
            address(this),
            assets,
            amounts,
            new uint256[](1),
            address(this),
            params,
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
        (address asset, uint256 amount) = abi.decode(params, (address, uint256));
        IERC20(asset).approve(address(pool), amount);
        pool.supply(asset, amount, address(this), 0);
        
        return true;
    }
}