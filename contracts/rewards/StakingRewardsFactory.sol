//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.1;

import "../interfaces/IStakingRewards.sol";
import "./RewardsDistributionRecipient.sol";
import "./ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./StakingRewards.sol";

contract StakingRewardsFactory is Ownable {
    address public rewardsToken;
    uint public stakingRewardsGenesis;

    address[] public stakingTokens;

    struct StakingRewardsInfo {
        address stakingRewards;
        uint rewardAmount;
        uint duration;
    }

    struct RewardInfo {
        uint boundingPeriod;
        uint rewardAmount;
        uint duration;
    }

    mapping(address => uint[]) private unBoundingPeriodByAddrInfo;
    mapping(address => mapping(uint => StakingRewardsInfo)) public stakingRewardsInfoByStakingToken;
    //mapping(address => StakingRewardsInfo) public stakingRewardsInfoByStakingToken;

    constructor(
        address _rewardsToken,
        uint _stakingRewardsGenesis
    ) Ownable() {
        require(_stakingRewardsGenesis >= block.timestamp, 'StakingRewardsFactory::constructor: genesis too soon');

        rewardsToken = _rewardsToken;
        stakingRewardsGenesis = _stakingRewardsGenesis;
    }

    function deploy(address stakingToken, RewardInfo[] memory rewardInfo) public onlyOwner {
        mapping(uint => StakingRewardsInfo) storage infoMap = stakingRewardsInfoByStakingToken[stakingToken];
        for (uint i = 0; i < rewardInfo.length; i++) {
            uint unBoundingPeriod = rewardInfo[i].boundingPeriod;
            StakingRewardsInfo storage info = infoMap[unBoundingPeriod];
            require(info.stakingRewards == address(0), 'StakingRewardsFactory::deploy: already deployed');
            info.stakingRewards = address(new StakingRewards(address(this), rewardsToken, stakingToken));
            info.rewardAmount = rewardInfo[i].rewardAmount;
            info.duration = rewardInfo[i].duration;
            unBoundingPeriodByAddrInfo[stakingToken].push(unBoundingPeriod);
            emit RewardAddr(info.stakingRewards);
        }
    }

    function update(address stakingToken, uint rewardAmount, uint256 rewardsDuration) public onlyOwner {
        mapping(uint => StakingRewardsInfo) storage infoMap = stakingRewardsInfoByStakingToken[stakingToken];
        StakingRewardsInfo storage info = infoMap[rewardsDuration];
        require(info.stakingRewards != address(0), 'StakingRewardsFactory::update: not deployed');

        info.rewardAmount = rewardAmount;
        info.duration = rewardsDuration;
    }

    function notifyRewardAmounts() public {
        require(stakingTokens.length > 0, 'StakingRewardsFactory::notifyRewardAmounts: called before any deploys');
        for (uint i = 0; i < stakingTokens.length; i++) {
            notifyRewardAmount(stakingTokens[i]);
        }
    }

    function notifyRewardAmount(address stakingToken) public {
        require(block.timestamp >= stakingRewardsGenesis, 'StakingRewardsFactory::notifyRewardAmount: not ready');
        emit CHECK(block.timestamp, stakingRewardsGenesis);
        mapping(uint => StakingRewardsInfo) storage infoMap = stakingRewardsInfoByStakingToken[stakingToken];
        uint[] storage unboundPeriod = unBoundingPeriodByAddrInfo[stakingToken];
        for (uint i = 0; i < unboundPeriod.length; i++) {
            StakingRewardsInfo storage info = infoMap[unboundPeriod[i]];
            require(info.stakingRewards != address(0), 'StakingRewardsFactory::notifyRewardAmount: not deployed');

            if (info.rewardAmount > 0 && info.duration > 0) {
                uint rewardAmount = info.rewardAmount;
                uint256 duration = info.duration;
                info.rewardAmount = 0;
                info.duration = 0;

                require(
                    IERC20(rewardsToken).transfer(info.stakingRewards, rewardAmount),
                    'StakingRewardsFactory::notifyRewardAmount: transfer failed'
                );
                StakingRewards(info.stakingRewards).notifyRewardAmount(rewardAmount, duration);
            }
        }
    }

    function pullExtraTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    event CHECK(uint timestamp, uint genesis);
    event RewardAddr(address stakingreward);
}