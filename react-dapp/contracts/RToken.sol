//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RToken is ERC20 {
    // constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    constructor() ERC20("Rick Token", "R") {
        _mint(msg.sender, 1000000 * (10 ** 18));
    }
}