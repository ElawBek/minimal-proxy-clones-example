// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./interfaces/IToken.sol";

/**
 * @title TestToken
 * @author Dmitry K. (@elawbek)
 *
 * @dev Test token, clones of which will be created in the factory
 */
contract TestToken is
  Initializable,
  ERC20Upgradeable,
  ERC20BurnableUpgradeable,
  OwnableUpgradeable,
  ERC20PermitUpgradeable
{
  /// @notice any opportunity to initialize the original contract is removed
  constructor() {
    _disableInitializers();
  }

  /// @notice initialization function
  function initialize(string calldata _name, string calldata _symbol)
    public
    initializer
  {
    __ERC20_init(_name, _symbol);
    __ERC20Burnable_init();
    __Ownable_init();
    __ERC20Permit_init(_name);
  }

  function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
  }
}
