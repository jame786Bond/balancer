//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

 contract BalancerToken is ERC20,ERC20Burnable {

    constructor() ERC20('Balancer Pool Token','BPT') {}

    function mint(address to,uint256 amount) public{
        _mint(to,amount);
    }

    function _push(address to, uint256 amount) internal returns(bool){
        uint256 balance =balanceOf(address(this));
        require(balance >=amount, "ERR_AMOUNT_EXCED");
        transferFrom(address(this),to,amount);
        return(true);
    }

    function _pull(address from , uint256 amount) internal returns(bool){
        uint256 balance =balanceOf(from);
        require(balance >=amount, "ERR_AMOUNT_EXCED");
        transferFrom(from,address(this),amount);
        return(true);
    }

    // function burn(uint256 amount) internal returns(bool){
    //     _burn(address[this],amount);
    // }


//    string  private _name     = "Balancer Pool Token";
//    string  private _symbol   = "BPT";
//    uint8   private _decimals = 18;
//
//    function name() public view returns (string memory) {
//        return _name;
//    }
//
//    function symbol() public view returns (string memory) {
//        return _symbol;
//    }
//
//    function decimals() public view returns(uint8) {
//        return _decimals;
//    }

//    function allowance(address src, address dst) external view returns (uint) {
//        return _allowance[src][dst];
//    }
//
//    function balanceOf(address whom) external view returns (uint) {
//        return _balance[whom];
//    }
//
//    function totalSupply() public view returns (uint) {
//        return _totalSupply;
//    }
//
//    function approve(address dst, uint amt) external returns (bool) {
//        _allowance[msg.sender][dst] = amt;
//        emit Approval(msg.sender, dst, amt);
//        return true;
//    }
//
//    function increaseApproval(address dst, uint amt) external returns (bool) {
//        _allowance[msg.sender][dst] = badd(_allowance[msg.sender][dst], amt);
//        emit Approval(msg.sender, dst, _allowance[msg.sender][dst]);
//        return true;
//    }
//
//    function decreaseApproval(address dst, uint amt) external returns (bool) {
//        uint oldValue = _allowance[msg.sender][dst];
//        if (amt > oldValue) {
//            _allowance[msg.sender][dst] = 0;
//        } else {
//            _allowance[msg.sender][dst] = bsub(oldValue, amt);
//        }
//        emit Approval(msg.sender, dst, _allowance[msg.sender][dst]);
//        return true;
//    }
//
//    function transfer(address dst, uint amt) external returns (bool) {
//        move(msg.sender, dst, amt);
//        return true;
//    }
//
//    function transferFrom(address src, address dst, uint amt) external returns (bool) {
//        require(msg.sender == src || amt <= _allowance[src][msg.sender], "ERR_BTOKEN_BAD_CALLER");
//        move(src, dst, amt);
//        if (msg.sender != src && _allowance[src][msg.sender] != uint256(-1)) {
//            _allowance[src][msg.sender] = bsub(_allowance[src][msg.sender], amt);
//            emit Approval(msg.sender, dst, _allowance[src][msg.sender]);
//        }
//        return true;
//    }

}