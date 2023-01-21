////SPDX-License-Identifier: Apache-2.0
//pragma solidity ^0.8.1;
//
//import "./BNum.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//
//contract BTokenBase is BNum, ERC20{
//
//    mapping(address => uint)                   internal _balance;
//    mapping(address => mapping(address=>uint)) internal _allowance;
//    uint internal _totalSupply;
//
//    function mint(uint amt) internal {
//        _balance[address(this)] = badd(_balance[address(this)], amt);
//        _totalSupply = badd(_totalSupply, amt);
//        emit Transfer(address(0), address(this), amt);
//    }
//
//    function burn(uint amt) internal {
//        require(_balance[address(this)] >= amt, "ERR_INSUFFICIENT_BAL");
//        _balance[address(this)] = bsub(_balance[address(this)], amt);
//        _totalSupply = bsub(_totalSupply, amt);
//        emit Transfer(address(this), address(0), amt);
//    }
//
//    function move(address src, address dst, uint amt) internal {
//        require(_balance[src] >= amt, "ERR_INSUFFICIENT_BAL");
//        _balance[src] = bsub(_balance[src], amt);
//        _balance[dst] = badd(_balance[dst], amt);
//        emit Transfer(src, dst, amt);
//    }
//
//    function push(address to, uint amt) internal {
//        move(address(this), to, amt);
//    }
//
//    function pull(address from, uint amt) internal {
//        move(from, address(this), amt);
//    }
//}