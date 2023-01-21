//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.1;

import "./BalancerFactory.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract BalancerDex is BNum {

    event LOG_JOIN(address indexed caller, address indexed tokenIn, uint256 tokenAmountIn);

    struct TokenParam {
        address token;
        uint balance;
        uint denormWt;
    }

    constructor(){}

    function createPool(TokenParam[] memory tokenParam, address bFactory, uint swapFee) external {
        BalancerPool bPool = IBFactory(bFactory).newBPool(msg.sender);
        for (uint i = 0; i < tokenParam.length; i++) {
            address token = tokenParam[i].token;
            uint balance = tokenParam[i].balance;
            uint denorm = tokenParam[i].denormWt;

            IERC20(token).transferFrom(msg.sender, address(this), balance);
            IERC20(token).approve(address(bPool), balance);
            bPool.bind(token, balance, denorm, msg.sender);
        }
        if (swapFee != 0) {
            uint calSwapFee = 100 / swapFee;
            bPool.setSwapFee(calSwapFee);
        }
        bPool.finalize(address(bPool), msg.sender);
    }

    function getSpotPrice(BalancerPool bPool, address token1, address token2) external view returns (uint){
        return bPool.getSpotPrice(token1, token2);
    }

    function swapExactAmtIn(uint tokenAAmount, address bPool, address token1, address token2) external {
        uint price = BalancerPool(bPool).getSpotPrice(token1, token2);
        uint tkn2Amount = price * tokenAAmount;
        IERC20(token2).approve(bPool, tkn2Amount);
        BalancerPool(bPool).swapExactAmountIn(
            address(token1),
            tokenAAmount,
            address(token2),
            tkn2Amount,
            price
        );
    }

    function swapExactAmtOut(uint token2Amt, address bPool, address token1, address token2) external {
        uint price = 110 * BalancerPool(bPool).getSpotPrice(token1, token2);
        uint token1Amt = price * token2Amt;
        IERC20(token1).approve(bPool, token1Amt);
        BalancerPool(bPool).swapExactAmountOut(
            token1,
            token1Amt,
            token2,
            token2Amt,
            price
        );
    }

    function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn, BalancerPool bPool) external {
        require(bPool.isFinalized(), "ERR_NOT_FINALIZED");
        uint poolTotal = bPool.getPoolTotal();
        uint ratio = bdiv(poolAmountOut, poolTotal);
        require(ratio != 0, "ERR_MATH_APPROX");

        address[] memory tokens = bPool.getCurrentTokens();
        for (uint i = 0; i < tokens.length; i++) {
            uint balance = bPool.getBalance(tokens[i]);
            uint tokenAmountIn = bmul(ratio, balance);
            require(tokenAmountIn != 0, "ERR_MATH_APPROX");
            require(tokenAmountIn <= maxAmountsIn[i], "ERR_LIMIT_IN");
            //IERC20(tokens[i]).approve(address(this), tokenAmountIn);
            bPool.updateRecordBalance(tokens[i], tokenAmountIn);
            emit LOG_JOIN(msg.sender, tokens[i], tokenAmountIn);
            IERC20(tokens[i]).transferFrom(msg.sender, address(bPool), tokenAmountIn);
        }
        bPool.joinPool(msg.sender, poolAmountOut);
    }

    function exitPool(uint poolAmountIn, uint[] calldata minAmountsOut, BalancerPool bPool, address bToken) external {
        //manually approve dex addr to transfer token from sender to bpool addr
        IERC20(bToken).transferFrom(msg.sender, address(bPool), poolAmountIn);
        bPool.exitPool(poolAmountIn, minAmountsOut, msg.sender);
    }
}
