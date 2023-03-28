pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";

contract BurnableToken is ERC20BurnableUpgradeable {

    function initialize() initializer public {
        __ERC20_init("MyToken", "MTK");
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
