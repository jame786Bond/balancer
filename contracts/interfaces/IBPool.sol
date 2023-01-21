//SPDX-License-Identifier: Apache-2.0
// pragma solidity ^0.8.1;

// interface IBPool {

//     function isPublicSwap() external view returns (bool);

//     function isFinalized() external view returns (bool);

//     function isBound(address t) external view returns (bool);

//     function getNumTokens() external view returns (uint); // temporary

//     function getCurrentTokens() external view viewLock returns (address[] memory tokens);

//     function getFinalTokens() external view viewLock returns (address[] memory tokens); // temp

//     function getDenormalizedWeight(address token) external view viewLock returns (uint);

//     function getTotalDenormalizedWeight() external view viewLock returns (uint);

//     function getNormalizedWeight(address token) external view viewLock returns (uint);

//     function getBalance(address token) external view viewLock returns (uint);

//     function getSwapFee() external view viewLock returns (uint);

//     function getController() external view viewLock returns (address);

//     function setSwapFee(uint swapFee) external logCall _lock_;

//     function setController(address manager) external logCall _lock_;

//     function setPublicSwap(bool public_) external logCall _lock_;

//     function finalize() external logCall _lock_;

//     function bind(address token, uint balance, uint denorm) external logCall;

//     function rebind(address token, uint balance, uint denorm) public logCall _lock_;

//     function unbind(address token) external logCall _lock_;

//     function gulp(address token) external logCall _lock_;

//     function getSpotPrice(address tokenIn, address tokenOut) external view viewLock returns (uint spotPrice);

//     function getSpotPriceSansFee(address tokenIn, address tokenOut) external view viewLock returns (uint spotPrice);

//     function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn) external logCall _lock_;

//     function exitPool(uint poolAmountIn, uint[] calldata minAmountsOut) external logCall _lock_;

//     function swapExactAmountIn(
//         address tokenIn,
//         uint tokenAmountIn,
//         address tokenOut,
//         uint minAmountOut,
//         uint maxPrice
//     ) external
//     logCall
//     _lock_
//     returns (uint tokenAmountOut, uint spotPriceAfter);

//     function swapExactAmountOut(
//         address tokenIn,
//         uint maxAmountIn,
//         address tokenOut,
//         uint tokenAmountOut,
//         uint maxPrice
//     )
//     external
//     logCall
//     _lock_
//     returns (uint tokenAmountIn, uint spotPriceAfter);

//     function joinSwapExternAmountIn(
//         address tokenIn,
//         uint tokenAmountIn,
//         uint minPoolAmountOut
//     )
//     external
//     logCall
//     _lock_
//     returns (uint poolAmountOut);

//     function joinSwapPoolAmountOut
//     (
//         address tokenIn,
//         uint poolAmountOut,
//         uint maxAmountIn
//     )
//     external
//     logCall
//     _lock_
//     returns (uint tokenAmountIn);

//     function exitSwapPoolAmountIn(
//         address tokenOut,
//         uint poolAmountIn,
//         uint minAmountOut
//     )
//     external
//     logCall
//     _lock_
//     returns (uint tokenAmountOut);

//     function exitSwapExternAmountOut(
//         address tokenOut,
//         uint tokenAmountOut,
//         uint maxPoolAmountIn
//     )
//     external
//     logCall
//     _lock_
//     returns (uint poolAmountIn);
// }
