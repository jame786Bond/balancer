//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.1;

abstract contract RewardsDistributionRecipient {
    address public rewardsDistribution; // admin address

    function notifyRewardAmount(uint256 reward, uint256 duration) virtual external;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }
}
