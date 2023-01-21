//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {

    constructor() ERC20('Reward Token', 'Orbis') {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }
}