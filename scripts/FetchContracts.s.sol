// SPDX-License-Identifier: MIT 
// scripts/FetchContracts.s.sol
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

contract FetchContracts is Script {
    function run() external {
        string memory output = vm.toString(
            vm.readFile("contracts/ZeroLendPool.sol")
        );
        console.log(output);
    }
}