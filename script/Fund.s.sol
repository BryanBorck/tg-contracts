// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/FundFactory.sol";

contract DeployScript is Script {
    function run() external {
        // Start the deployment transaction
        vm.startBroadcast();

        // Deploy the Factory contract
        Factory factory = new Factory();

        // Define parameters for creating a new Fund and FundToken
        address beneficiary = address(0x604Aa35b72a1C0b2B7e0973430d1E58366d3e347);
        uint256 targetAmount = 0.01 ether;
        uint256 lockDuration = 30 days;
        string memory tokenName = "Tester";
        string memory tokenSymbol = "Test";

        // Call createFund to deploy a new Fund and FundToken
        factory.createFund(beneficiary, targetAmount, lockDuration, tokenName, tokenSymbol);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}