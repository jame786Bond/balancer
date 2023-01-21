//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.1;

interface IStakingRewards {
    // Views
    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    // Mutative

    function stake(uint256 amount, address owner) external;

    function unboundingPeriod(uint unboundPeriod) external;

    function getReward() external;

    function exit() external;
}
