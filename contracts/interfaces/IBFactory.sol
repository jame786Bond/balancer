pragma solidity ^0.8.1;

import "../BalancerPool.sol";

interface IBFactory {
    function newBPool(address owner) external returns (BalancerPool);

    function setBLabs(address b) external;

    function isBalancerPool(address balancerAddr) external view returns (bool);

    function collect(BalancerPool pool) external;

    function getBLabs() external view returns (address);
}
