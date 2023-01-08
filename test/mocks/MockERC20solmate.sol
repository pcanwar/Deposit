// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;
import {ERC20} from "solmate/tokens/ERC20.sol";

contract MockERC20solmate is ERC20 {
    constructor(string memory _name, string memory _sym)
        ERC20(_name, _sym, 18)
    {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
