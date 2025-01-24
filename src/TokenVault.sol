// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC4626} from "lib/openzeppelin-contracts/contracts/interfaces/IERC4626.sol";
import {ERC4626} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

abstract contract TokenVault is ERC4626 {

    mapping (address => uint) public shareHolders;

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset) {}

    function _deposit(uint assets) public {
        deposit(assets, msg.sender);
        shareHolders[msg.sender] += assets;
    }

    function withdraw(uint _shares, address _receiver) public {
        require(shareHolders[_receiver] > 0, "Holder don't have share");
        require(_receiver != address(0), "Invalid address");
        require(_shares > 0, "withdraw is less then zero");
        require(shareHolders[_receiver] >= _shares, "Not enough share");
        uint percent = (_shares * 10) / 100;
        uint assets = _shares + percent;
        redeem(assets, _receiver, msg.sender);
        shareHolders[_receiver] -= assets;
    }

    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    function totalAssetsOfUser(address _user) public view returns (uint256) {
        return asset.balanceOf(_user);
    }
}

contract USDC is ERC20 {
    constructor() ERC20("USDC", "USDC") {}

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}
