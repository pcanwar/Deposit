// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import {ERC20, ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract MockERC20 is ERC20, ERC20Permit {
    constructor(string memory _name, string memory _sym)
        ERC20(_name, _sym)
        ERC20Permit(_name)
    {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
