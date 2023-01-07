// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory _name, string memory _sym) ERC20(_name, _sym) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
