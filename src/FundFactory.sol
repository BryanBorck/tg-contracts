// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Fund.sol";
import "./FundToken.sol";

contract Factory {
    address[] public funds;

    event FundCreated(address indexed fundAddress, address indexed beneficiary);

    function createFund(
        address beneficiary,
        uint256 targetAmount,
        uint256 lockDuration,
        string memory tokenName,
        string memory tokenSymbol
    ) external {
        // Deploy the FundToken contract
        FundToken token = new FundToken(tokenName, tokenSymbol, address(this)); // Factory is the owner

        // Deploy the Fund contract
        Fund fund = new Fund(beneficiary, targetAmount, lockDuration, address(token), address(this)); // Factory is the owner

        token.transferOwnership(address(fund));

        funds.push(address(fund));

        emit FundCreated(address(fund), beneficiary);
    }

    function getFunds() external view returns (address[] memory) {
        return funds;
    }
}