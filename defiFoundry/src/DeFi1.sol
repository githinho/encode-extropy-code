//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "./Token.sol";

contract DeFi1 {
    // set as immutable
    uint256 initialAmount = 0;
    // set as immutable
    Token public token;
    uint256 blockReward = 0;
    address[] public investors;

    constructor(uint256 _initialAmount, uint256 _blockReward) {
        initialAmount = initialAmount;
        token = new Token(_initialAmount);
        blockReward = _blockReward;
    }

    // this function should have modifier onlyOwner or administrator
    function addInvestor(address _investor) public {
        investors.push(_investor);
    }

    function claimTokens() public {
        bool found = false;
        // payout is alyways 0
        uint256 payout = 0;

        for (uint256 ii = 0; ii < investors.length; ii++) {
            if (investors[ii] == msg.sender) {
                found = true;
                // use break after first true
                // just call calculatePayout() and token.transfer() from here without bool found
                // break;
            } else {
                found = false;
            }
        }
        if (found == true) {
            // set returned value to payout variable
            calculatePayout();
        }

        token.transfer(msg.sender, payout);
    }

    // set this function as private
    function calculatePayout() public returns (uint256) {
        uint256 payout = 0;
        // problem with naming
        uint256 blockReward = blockReward;
        blockReward = block.number % 1000;
        payout = initialAmount / investors.length;
        payout = payout * blockReward;
        blockReward--;
        return payout;
    }

    // added for testing purposes
    function getInvestorsCount() public returns (uint256) {
        return investors.length;
    }
}
