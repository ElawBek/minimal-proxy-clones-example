// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IToken {
  function initialize(string calldata name, string calldata symbol) external;

  function transferOwnership(address newOwner) external;
}
