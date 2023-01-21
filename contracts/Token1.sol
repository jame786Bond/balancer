//SPDX-License-Identifier: Apache-2.0
pragma solidity ^ 0.8.1;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract Token1 is ERC20{
constructor() ERC20('Token1','T1') {}

function mint(address to,uint256 amount) public {
        _mint(to,amount);
    }



}