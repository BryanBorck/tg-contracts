// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Mintable is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract Fund is Ownable {
    IERC20Mintable public fundToken;
    address public beneficiary;
    uint256 public targetAmount;
    uint256 public lockedUntil;
    uint256 public totalFunds;
    uint256 public splitsRemaining = 5;
    bool public guaranteeLocked;

    mapping(address => uint256) public funds;
    address[] public funders;

    event FundsReceived(address indexed donor, uint256 amount);
    event FundsReleased(address indexed beneficiary, uint256 amount);

    constructor(
        address _beneficiary,
        uint256 _targetAmount,
        uint256 _lockDuration,
        address _tokenAddress,
        address initialOwner
    ) Ownable(initialOwner) {
        beneficiary = _beneficiary;
        targetAmount = _targetAmount;
        lockedUntil = block.timestamp + _lockDuration;
        fundToken = IERC20Mintable(_tokenAddress);
    }

    function fund() external payable {
        require(msg.value > 0, "Funding must be greater than zero");

        if (funds[msg.sender] == 0) {
            funders.push(msg.sender);
        }

        funds[msg.sender] += msg.value;
        totalFunds += msg.value;

        fundToken.mint(msg.sender, msg.value);

        emit FundsReceived(msg.sender, msg.value);
    }

    function lockGuarantee() external payable onlyBeneficiary {
        require(!guaranteeLocked, "Guarantee already locked");
        uint256 requiredGuarantee = (targetAmount * 10) / 100;
        require(msg.value >= requiredGuarantee, "Insufficient guarantee amount");

        guaranteeLocked = true;
    }

    function verify() public pure returns (bool) {
        return true;
    }

    function releaseFunds() external onlyBeneficiary {
        require(block.timestamp >= lockedUntil, "Funds are still locked");
        require(verify(), "Verification failed");
        require(splitsRemaining > 0, "All splits have been released");

        uint256 amountToRelease = totalFunds / 5;
        splitsRemaining--;
        payable(beneficiary).transfer(amountToRelease);

        emit FundsReleased(beneficiary, amountToRelease);
    }

    function distributeGuarantee() external {
        require(splitsRemaining == 0, "Funds still being released");
        require(guaranteeLocked, "Guarantee not locked");

        uint256 guaranteeAmount = (targetAmount * 10) / 100;
        uint256 totalSupply = fundToken.totalSupply();

        for (uint256 i = 0; i < funders.length; i++) {
            address donor = funders[i];
            uint256 holderBalance = fundToken.balanceOf(donor);
            uint256 share = (guaranteeAmount * holderBalance) / totalSupply;
            payable(donor).transfer(share);
        }

        guaranteeLocked = false;
    }

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Only beneficiary can call this");
        _;
    }
}