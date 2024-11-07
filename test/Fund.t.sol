// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/FundFactory.sol";
import "../src/Fund.sol";
import "../src/FundToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FundTest is Test {
    Factory factory;

    function setUp() public {
        // Deploy the Factory contract
        factory = new Factory();
    }

    function testCreateFundAndDonate() public {
        // Parameters for creating the Fund
        address beneficiary = address(0x123);
        uint256 targetAmount = 100 ether;
        uint256 lockDuration = 30 days;
        string memory tokenName = "FundToken";
        string memory tokenSymbol = "FTK";

        // Use the factory to create a new Fund
        factory.createFund(beneficiary, targetAmount, lockDuration, tokenName, tokenSymbol);

        // Retrieve the created fund address
        address[] memory funds = factory.getFunds();
        assertEq(funds.length, 1, "Funds array should contain one fund");

        // Get the Fund contract
        Fund fund = Fund(funds[0]);

        // Check that the beneficiary is set correctly
        assertEq(fund.beneficiary(), beneficiary, "Beneficiary should be set correctly");

        // Get the FundToken contract
        FundToken fundToken = FundToken(address(fund.fundToken()));

        // Check that the token name and symbol are correct
        assertEq(fundToken.name(), tokenName, "Token name should match");
        assertEq(fundToken.symbol(), tokenSymbol, "Token symbol should match");

        // Simulate a donor donating to the fund
        address donor = address(0x456);
        vm.deal(donor, 10 ether); // Assign 10 ether to the donor

        // Donor makes a donation of 1 ether
        vm.prank(donor); // Set the next call to be from the donor
        fund.fund{value: 1 ether}();

        // Check that the donor received FundTokens
        uint256 donorTokenBalance = fundToken.balanceOf(donor);
        assertEq(donorTokenBalance, 1 ether, "Donor should receive tokens equal to the donation amount");

        // Check that totalDonations increased
        uint256 totalDonations = fund.totalDonations();
        assertEq(totalDonations, 1 ether, "Total donations should be updated");
    }
}