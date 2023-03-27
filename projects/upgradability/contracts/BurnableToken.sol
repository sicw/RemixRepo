pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";

import "hardhat/console.sol";

contract BurnableToken is ERC20BurnableUpgradeable {

    // 这块sb了, 执行构造函数后 数据不就保存到当前合约了么
    //    constructor() ERC20("token", "TK") {
    //    }

    function initialize() initializer public {
        __ERC20_init("MyToken", "MTK");
    }

    function burn(uint256 amount) public override {
        console.log("msg.sender %s burn count %d", msg.sender, amount);
    }

    function _spendAllowance(address account, uint256 amount) public {

    }

    function mint(address account, uint256 amount) public {
        console.log("msg.sender %s mint %s count: %d", msg.sender, account, amount);
        _mint(account, amount);
        uint256 count = balanceOf(account);
        console.log("after count %d", count);
    }
}
