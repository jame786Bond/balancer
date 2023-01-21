//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./BConst.sol";
import "./BMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BalancerPool is BMath, IERC20, ERC20("Balancer token", "BPT") {

    struct Record {
        bool bound;   // is token bound to pool
        uint index;   // private
        uint denorm;  // denormalized weight
        uint balance;
    }

    bool private _mutex;
    address private _factory;    // BFactory address to push token exitFee to
    address private _controller; // has CONTROL role
    bool private _publicSwap; // true if PUBLIC can call SWAP functions

    // `setSwapFee` and `finalize` require CONTROL
    // `finalize` sets `PUBLIC can SWAP`, `PUBLIC can JOIN`
    uint private _swapFee;
    bool private _finalized;
    address[] private _tokens;
    mapping(address => Record) private  _records;
    uint private _totalWeight;

    constructor() {
        _controller = msg.sender;
        _factory = msg.sender;
        _swapFee = MIN_FEE;
        _publicSwap = false;
        _finalized = false;
    }

    modifier logCall() {
        emit LOG_CALL(msg.sig, msg.sender, msg.data);
        _;
    }

    modifier _lock_() {
        require(!_mutex, "ERR_REENTRY");
        _mutex = true;
        _;
        _mutex = false;
    }

    modifier viewLock() {
        require(!_mutex, "ERR_REENTRY");
        _;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function isPublicSwap() external view returns (bool){
        return _publicSwap;
    }

    function isFinalized() external view returns (bool){
        return _finalized;
    }

    function isBound(address t) external view returns (bool){
        return _records[t].bound;
    }

    function getNumTokens() external view returns (uint){
        return _tokens.length;
    }

    function getCurrentTokens() external view viewLock returns (address[] memory tokens){
        return _tokens;
    }

    function getFinalTokens() external view viewLock returns (address[] memory tokens){
        require(_finalized, "ERR_NOT_FINALIZED");
        return _tokens;
    }

    function getDenormalizedWeight(address token) external view viewLock returns (uint){
        require(_records[token].bound, "ERR_NOT_BOUND");
        return _records[token].denorm;
    }

    function getTotalDenormalizedWeight() external view viewLock returns (uint){
        return _totalWeight;
    }

    function getNormalizedWeight(address token) external view viewLock returns (uint){
        require(_records[token].bound, "ERR_NOT_BOUND");
        uint denorm = _records[token].denorm;
        return bdiv(denorm, _totalWeight);
    }

    function getBalance(address token) external view viewLock returns (uint){
        require(_records[token].bound, "ERR_NOT_BOUND");
        return _records[token].balance;
    }

    function getSwapFee() external view viewLock returns (uint){
        return _swapFee;
    }

    function getController() external view viewLock returns (address){
        return _controller;
    }

    function updateRecordBalance(address token, uint tokenAmountIn) external {
        _records[token].balance = badd(_records[token].balance, tokenAmountIn);
    }

    function setSwapFee(uint swapFee) external logCall _lock_ {
        require(!_finalized, "ERR_IS_FINALIZED");
        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        require(swapFee >= MIN_FEE, "ERR_MIN_FEE");
        require(swapFee <= MAX_FEE, "ERR_MAX_FEE");
        _swapFee = swapFee;
    }

    function setController(address manager) external logCall _lock_ {
        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        _controller = manager;
    }

    function setPublicSwap(bool public_) external logCall _lock_ {
        require(!_finalized, "ERR_IS_FINALIZED");
        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        _publicSwap = public_;
    }

    function finalize(address bPool, address owner) external logCall _lock_ {
        require(owner == _controller, "ERR_NOT_CONTROLLER");
        require(!_finalized, "ERR_IS_FINALIZED");
        require(_tokens.length >= MIN_BOUND_TOKENS, "ERR_MIN_TOKENS");

        _finalized = true;
        _publicSwap = true;
        mint(bPool, INIT_POOL_SUPPLY);
        //_mintPoolShare(bPool, INIT_POOL_SUPPLY);
        //_pushPoolShare(msg.sender, INIT_POOL_SUPPLY);
    }

    // _lock_  Bind does not lock because it jumps to `rebind`, which does
    function bind(address token, uint balance, uint denorm, address owner) external logCall {
        require(owner == _controller, "ERR_NOT_CONTROLLER");
        require(!_records[token].bound, "ERR_IS_BOUND");
        require(!_finalized, "ERR_IS_FINALIZED");
        require(_tokens.length < MAX_BOUND_TOKENS, "ERR_MAX_TOKENS");

        _records[token] = Record({
        bound : true,
        index : _tokens.length,
        denorm : 0, // balance and denorm will be validated
        balance : 0   // and set by `rebind`
        });
        _tokens.push(token);
        rebind(token, balance, denorm, owner);
    }

    function rebind(address token, uint balance, uint denorm, address owner) public logCall _lock_ {
        require(owner == _controller, "ERR_NOT_CONTROLLER");
        require(_records[token].bound, "ERR_NOT_BOUND");
        require(!_finalized, "ERR_IS_FINALIZED");

        require(denorm >= MIN_WEIGHT, "ERR_MIN_WEIGHT");
        require(denorm <= MAX_WEIGHT, "ERR_MAX_WEIGHT");
        require(balance >= MIN_BALANCE, "ERR_MIN_BALANCE");

        // Adjust the denorm and totalWeight
        uint oldWeight = _records[token].denorm;
        if (denorm > oldWeight) {
            _totalWeight = badd(_totalWeight, bsub(denorm, oldWeight));
            require(_totalWeight <= MAX_TOTAL_WEIGHT, "ERR_MAX_TOTAL_WEIGHT");
        } else if (denorm < oldWeight) {
            _totalWeight = bsub(_totalWeight, bsub(oldWeight, denorm));
        }
        _records[token].denorm = denorm;

        // Adjust the balance record and actual token balance
        uint oldBalance = _records[token].balance;
        _records[token].balance = balance;
        if (balance > oldBalance) {
            _pullUnderlying(token, msg.sender, bsub(balance, oldBalance));
        } else if (balance < oldBalance) {
            // In this case liquidity is being withdrawn, so charge EXIT_FEE
            uint tokenBalanceWithdrawn = bsub(oldBalance, balance);
            uint tokenExitFee = bmul(tokenBalanceWithdrawn, EXIT_FEE);
            _pushUnderlying(token, msg.sender, bsub(tokenBalanceWithdrawn, tokenExitFee));
            _pushUnderlying(token, _factory, tokenExitFee);
        }
    }

    function unbind(address token) external logCall _lock_ {
        require(msg.sender == _controller, "ERR_NOT_CONTROLLER");
        require(_records[token].bound, "ERR_NOT_BOUND");
        require(!_finalized, "ERR_IS_FINALIZED");

        uint tokenBalance = _records[token].balance;
        uint tokenExitFee = bmul(tokenBalance, EXIT_FEE);

        _totalWeight = bsub(_totalWeight, _records[token].denorm);

        // Swap the token-to-unbind with the last token,
        // then delete the last token
        uint index = _records[token].index;
        uint last = _tokens.length - 1;
        _tokens[index] = _tokens[last];
        _records[_tokens[index]].index = index;
        _tokens.pop();
        _records[token] = Record({
        bound : false,
        index : 0,
        denorm : 0,
        balance : 0
        });
        _pushUnderlying(token, msg.sender, bsub(tokenBalance, tokenExitFee));
        _pushUnderlying(token, _factory, tokenExitFee);
    }

    function gulp(address token) external logCall _lock_ {
        require(_records[token].bound, "ERR_NOT_BOUND");
        _records[token].balance = IERC20(token).balanceOf(address(this));
    }

    function getSpotPrice(address tokenIn, address tokenOut)
    external
    view
    viewLock
    returns (uint spotPrice){
        require(_records[tokenIn].bound, "ERR_NOT_BOUND");
        require(_records[tokenOut].bound, "ERR_NOT_BOUND");
        Record storage inRecord = _records[tokenIn];
        Record storage outRecord = _records[tokenOut];
        return calcSpotPrice(inRecord.balance, inRecord.denorm, outRecord.balance, outRecord.denorm, _swapFee);
    }

    function getSpotPriceSansFee(address tokenIn, address tokenOut)
    external
    view
    viewLock
    returns (uint spotPrice){
        require(_records[tokenIn].bound, "ERR_NOT_BOUND");
        require(_records[tokenOut].bound, "ERR_NOT_BOUND");
        Record storage inRecord = _records[tokenIn];
        Record storage outRecord = _records[tokenOut];
        return calcSpotPrice(inRecord.balance, inRecord.denorm, outRecord.balance, outRecord.denorm, 0);
    }

    function getPoolTotal() public view returns (uint){
        return totalSupply();
    }

    function joinPool(address owner, uint poolAmountOut) external logCall _lock_ {
        mint(owner, poolAmountOut);
        //transfer(owner, poolAmountOut);
    }

    function exitPool(uint poolAmountIn, uint[] calldata minAmountsOut, address owner) external logCall _lock_ {
        require(_finalized, "ERR_NOT_FINALIZED");

        uint poolTotal = totalSupply();
        uint exitFee = bmul(poolAmountIn, EXIT_FEE);
        uint pAiAfterExitFee = bsub(poolAmountIn, exitFee);
        uint ratio = bdiv(pAiAfterExitFee, poolTotal);
        require(ratio != 0, "ERR_MATH_APPROX");
        emit EXIT_POOL(poolTotal, exitFee, pAiAfterExitFee, ratio);
        //lp token - user -> bPool addr
        //if require - puhs exit fee to factory addr
        //then burn the left token amt

        //transfer exit fee to factory
        transfer(_factory, exitFee);
        // transfer remaining amt to Balancer token addr
        transfer(address(this), poolAmountIn - exitFee);
        // burn remaining balancer token

        burn(address(this), pAiAfterExitFee);

        for (uint i = 0; i < _tokens.length; i++) {
            address outPutToken = _tokens[i];
            uint bal = _records[outPutToken].balance;
            uint tokenAmountOut = bmul(ratio, bal);
            emit EXIT_CHECK(outPutToken, bal, tokenAmountOut);
            require(tokenAmountOut != 0, "ERR_MATH_APPROX");
            require(tokenAmountOut >= minAmountsOut[i], "ERR_LIMIT_OUT");
            _records[outPutToken].balance = bsub(_records[outPutToken].balance, tokenAmountOut);
            emit LOG_EXIT(msg.sender, outPutToken, tokenAmountOut);
            // transfer token amt from pool to owner addr
            IERC20(outPutToken).transfer(owner, tokenAmountOut);
        }
    }



    function swapExactAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        address tokenOut,
        uint minAmountOut,
        uint maxPrice
    ) external
    logCall
    _lock_
    returns (uint tokenAmountOut, uint spotPriceAfter){
        require(_records[tokenIn].bound, "ERR_NOT_BOUND");
        require(_records[tokenOut].bound, "ERR_NOT_BOUND");
        require(_publicSwap, "ERR_SWAP_NOT_PUBLIC");

        Record storage inRecord = _records[tokenIn];
        Record storage outRecord = _records[tokenOut];

        require(tokenAmountIn <= bmul(inRecord.balance, MAX_IN_RATIO), "ERR_MAX_IN_RATIO");

        uint spotPriceBefore = calcSpotPrice(
            inRecord.balance,
            inRecord.denorm,
            outRecord.balance,
            outRecord.denorm,
            _swapFee
        );
        require(spotPriceBefore <= maxPrice, "ERR_BAD_LIMIT_PRICE");

        tokenAmountOut = calcOutGivenIn(
            inRecord.balance,
            inRecord.denorm,
            outRecord.balance,
            outRecord.denorm,
            tokenAmountIn,
            _swapFee
        );
        require(tokenAmountOut >= minAmountOut, "ERR_LIMIT_OUT");

        inRecord.balance = badd(inRecord.balance, tokenAmountIn);
        outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

        spotPriceAfter = calcSpotPrice(
            inRecord.balance,
            inRecord.denorm,
            outRecord.balance,
            outRecord.denorm,
            _swapFee
        );
        require(spotPriceAfter >= spotPriceBefore, "ERR_MATH_APPROX");
        require(spotPriceAfter <= maxPrice, "ERR_LIMIT_PRICE");
        require(spotPriceBefore <= bdiv(tokenAmountIn, tokenAmountOut), "ERR_MATH_APPROX");

        emit LOG_SWAP(msg.sender, tokenIn, tokenOut, tokenAmountIn, tokenAmountOut);

        _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);
        _pushUnderlying(tokenOut, msg.sender, tokenAmountOut);

        return (tokenAmountOut, spotPriceAfter);
    }


    function swapExactAmountOut(
        address tokenIn,
        uint maxAmountIn,
        address tokenOut,
        uint tokenAmountOut,
        uint maxPrice
    )
    external
    logCall
    _lock_
    returns (uint tokenAmountIn, uint spotPriceAfter){
        require(_records[tokenIn].bound, "ERR_NOT_BOUND");
        require(_records[tokenOut].bound, "ERR_NOT_BOUND");
        require(_publicSwap, "ERR_SWAP_NOT_PUBLIC");

        Record storage inRecord = _records[address(tokenIn)];
        Record storage outRecord = _records[address(tokenOut)];

        require(tokenAmountOut <= bmul(outRecord.balance, MAX_OUT_RATIO), "ERR_MAX_OUT_RATIO");

        uint spotPriceBefore = calcSpotPrice(
            inRecord.balance,
            inRecord.denorm,
            outRecord.balance,
            outRecord.denorm,
            _swapFee
        );
        require(spotPriceBefore <= maxPrice, "ERR_BAD_LIMIT_PRICE");

        tokenAmountIn = calcInGivenOut(
            inRecord.balance,
            inRecord.denorm,
            outRecord.balance,
            outRecord.denorm,
            tokenAmountOut,
            _swapFee
        );
        require(tokenAmountIn <= maxAmountIn, "ERR_LIMIT_IN");

        inRecord.balance = badd(inRecord.balance, tokenAmountIn);
        outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

        spotPriceAfter = calcSpotPrice(
            inRecord.balance,
            inRecord.denorm,
            outRecord.balance,
            outRecord.denorm,
            _swapFee
        );
        require(spotPriceAfter >= spotPriceBefore, "ERR_MATH_APPROX");
        require(spotPriceAfter <= maxPrice, "ERR_LIMIT_PRICE");
        require(spotPriceBefore <= bdiv(tokenAmountIn, tokenAmountOut), "ERR_MATH_APPROX");

        emit LOG_SWAP(msg.sender, tokenIn, tokenOut, tokenAmountIn, tokenAmountOut);

        _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);
        _pushUnderlying(tokenOut, msg.sender, tokenAmountOut);

        return (tokenAmountIn, spotPriceAfter);
    }


    function joinSwapExternAmountIn
    (
        address tokenIn,
        uint tokenAmountIn,
        uint minPoolAmountOut
    )
    external
    logCall
    _lock_
    returns (uint poolAmountOut){
        require(_finalized, "ERR_NOT_FINALIZED");
        require(_records[tokenIn].bound, "ERR_NOT_BOUND");
        require(tokenAmountIn <= bmul(_records[tokenIn].balance, MAX_IN_RATIO), "ERR_MAX_IN_RATIO");

        Record storage inRecord = _records[tokenIn];
        uint totalSupply = totalSupply();

        poolAmountOut = calcPoolOutGivenSingleIn(
            inRecord.balance,
            inRecord.denorm,
            totalSupply,
            _totalWeight,
            tokenAmountIn,
            _swapFee
        );

        require(poolAmountOut >= minPoolAmountOut, "ERR_LIMIT_OUT");

        inRecord.balance = badd(inRecord.balance, tokenAmountIn);

        emit LOG_JOIN(msg.sender, tokenIn, tokenAmountIn);

        _mintPoolShare(msg.sender, poolAmountOut);
        //_pushPoolShare(msg.sender, poolAmountOut);
        _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);

        return poolAmountOut;
    }

    function joinSwapPoolAmountOut
    (
        address tokenIn,
        uint poolAmountOut,
        uint maxAmountIn
    )
    external
    logCall
    _lock_
    returns (uint tokenAmountIn){
        require(_finalized, "ERR_NOT_FINALIZED");
        require(_records[tokenIn].bound, "ERR_NOT_BOUND");

        Record storage inRecord = _records[tokenIn];

        tokenAmountIn = calcSingleInGivenPoolOut(
            inRecord.balance,
            inRecord.denorm,
            totalSupply(),
            _totalWeight,
            poolAmountOut,
            _swapFee
        );

        require(tokenAmountIn != 0, "ERR_MATH_APPROX");
        require(tokenAmountIn <= maxAmountIn, "ERR_LIMIT_IN");

        require(tokenAmountIn <= bmul(_records[tokenIn].balance, MAX_IN_RATIO), "ERR_MAX_IN_RATIO");

        inRecord.balance = badd(inRecord.balance, tokenAmountIn);

        emit LOG_JOIN(msg.sender, tokenIn, tokenAmountIn);

        //_mintPoolShare(poolAmountOut);
        _pushPoolShare(msg.sender, poolAmountOut);
        _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);

        return tokenAmountIn;
    }

    function exitSwapPoolAmountIn
    (
        address tokenOut,
        uint poolAmountIn,
        uint minAmountOut
    )
    external
    logCall
    _lock_
    returns (uint tokenAmountOut){
        require(_finalized, "ERR_NOT_FINALIZED");
        require(_records[tokenOut].bound, "ERR_NOT_BOUND");

        Record storage outRecord = _records[tokenOut];

        tokenAmountOut = calcSingleOutGivenPoolIn(
            outRecord.balance,
            outRecord.denorm,
            IERC20(address(this)).totalSupply(),
            _totalWeight,
            poolAmountIn,
            _swapFee
        );

        require(tokenAmountOut >= minAmountOut, "ERR_LIMIT_OUT");

        require(tokenAmountOut <= bmul(_records[tokenOut].balance, MAX_OUT_RATIO), "ERR_MAX_OUT_RATIO");

        outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

        uint exitFee = bmul(poolAmountIn, EXIT_FEE);

        emit LOG_EXIT(msg.sender, tokenOut, tokenAmountOut);

        _pullPoolShare(msg.sender, poolAmountIn);
        _burnPoolShare(bsub(poolAmountIn, exitFee));
        _pushPoolShare(_factory, exitFee);
        _pushUnderlying(tokenOut, msg.sender, tokenAmountOut);

        return tokenAmountOut;
    }

    function exitSwapExternAmountOut
    (
        address tokenOut,
        uint tokenAmountOut,
        uint maxPoolAmountIn
    )
    external
    logCall
    _lock_
    returns (uint poolAmountIn){
        require(_finalized, "ERR_NOT_FINALIZED");
         require(_records[tokenOut].bound, "ERR_NOT_BOUND");
        require(tokenAmountOut <= bmul(_records[tokenOut].balance, MAX_OUT_RATIO), "ERR_MAX_OUT_RATIO");

        Record storage outRecord = _records[tokenOut];
        poolAmountIn = calcPoolInGivenSingleOut(
            outRecord.balance,
            outRecord.denorm,
            IERC20(address(this)).totalSupply(),
            _totalWeight,
            tokenAmountOut,
            _swapFee
        );

        require(poolAmountIn != 0, "ERR_MATH_APPROX");
        require(poolAmountIn <= maxPoolAmountIn, "ERR_LIMIT_IN");

        outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

        uint exitFee = bmul(poolAmountIn, EXIT_FEE);

        emit LOG_EXIT(msg.sender, tokenOut, tokenAmountOut);

        _pullPoolShare(msg.sender, poolAmountIn);
        _burnPoolShare(bsub(poolAmountIn, exitFee));
        _pushPoolShare(_factory, exitFee);
        _pushUnderlying(tokenOut, msg.sender, tokenAmountOut);

        return poolAmountIn;
    }

    // 'Underlying' token-manipulation functions make external calls but are NOT locked
    // You must `_lock_` or otherwise ensure reentry-safety

    function _pullUnderlying(address erc20, address from, uint amount) internal {
        bool xfer = IERC20(erc20).transferFrom(from, address(this), amount);
        require(xfer, "ERR_ERC20_FALSE");
    }

    function _pushUnderlying(address erc20, address to, uint amount) internal {
        bool xfer = IERC20(erc20).transfer(to, amount);
        require(xfer, "ERR_ERC20_FALSE");
    }

    function _pullPoolShare(address from, uint amount) internal {
        //_pull(from, amount);

    }

    function _pushPoolShare(address to, uint amount) internal {
        //_push(to, amount);
    }

    function _mintPoolShare(address to, uint amount) internal {
        mint(to, amount);
    }

    function _burnPoolShare(uint amount) internal {
        //_burn(amount);
    }

    event LOG_SWAP(address indexed caller, address indexed tokenIn, address indexed tokenOut, uint256 tokenAmountIn,
        uint256 tokenAmountOut);
    event LOG_JOIN(address indexed caller, address indexed tokenIn, uint256 tokenAmountIn);
    event LOG_EXIT(address indexed caller, address indexed tokenOut, uint256 tokenAmountOut);
    event LOG_CALL(bytes4  indexed sig, address indexed caller, bytes data) anonymous;
    event EXIT_POOL(uint poolTotal, uint exitFee, uint pAiAfterExitFee, uint ratio);
    event EXIT_CHECK(address t, uint bal, uint tokenamountout);
}
