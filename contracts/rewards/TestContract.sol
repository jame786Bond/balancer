//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.1;

import "./StakingRewards.sol";
import "../BalancerPool.sol";

contract TestContract {

    address public stakingReward;

    constructor(address _staking){
        stakingReward = _staking;
    }

    function stake(uint256 amount, address stakingToken) external {
        BalancerPool(stakingToken).mint(address(this), amount);
        IERC20(stakingToken).approve(stakingReward, amount);
        StakingRewards(stakingReward).stake(amount, msg.sender);
    }

    function getReward() external {
        StakingRewards(stakingReward).getReward();
    }

    function unboundingPeriod(uint duration) external {
        StakingRewards(stakingReward).unboundingPeriod(duration);
    }

    function exit() external {
        StakingRewards(stakingReward).exit();
    }
}
