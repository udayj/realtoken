// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstToken is ERC20, Ownable {
    uint256 private _cap;
    constructor(uint256 _cap1) ERC20("RealEstToken","REAL") {
        _mint(msg.sender, 100000 * 10 ** decimals());
        _cap=_cap1;
    }

    function cap() public view returns(uint256) {
        return _cap;
    }
    function mint(address to, uint256 amount) public onlyOwner {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        _mint(to, amount);
    }
}
