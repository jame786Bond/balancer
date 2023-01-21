//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.1;

import "./BalancerPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IBFactory.sol";

contract BalancerFactory is IBFactory {

    mapping(address => bool) private isBPool;
    address private blabs;
    constructor() {
        blabs = msg.sender;
    }

    function isBalancerPool(address balancerAddr) external view override returns (bool){
        return isBPool[balancerAddr];
    }

    function newBPool(address owner) external override returns (BalancerPool){
        BalancerPool bPool = new BalancerPool();
        isBPool[address(bPool)] = true;
        emit LOG_NEW_POOL(msg.sender, address(bPool));
        bPool.setController(owner);
        return bPool;
    }

    function getBLabs() external view override returns (address){
        return blabs;
    }

    function setBLabs(address b) external override {
        require(msg.sender == blabs, "ERR_NOT_BLABS");
        emit LOG_BLABS(msg.sender, b);
        blabs = b;
    }

    function collect(BalancerPool pool) external override {
        require(msg.sender == blabs, "ERR_NOT_BLABS");
        uint collected = IERC20(pool).balanceOf(address(this));
        bool xfer = pool.transfer(blabs, collected);
        require(xfer, "ERR_ERC20_FAILED");
    }

    event LOG_NEW_POOL(address indexed caller, address indexed pool);
    event LOG_BLABS(address indexed caller, address indexed blabs);
}
