// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IClonesTokenFactory {
  /// @param oldImpl - past address of implementation
  /// @param newImpl - new address of implementation
  event ImplementationChanged(address indexed oldImpl, address indexed newImpl);

  /// @param clone - address of the created clone
  /// @param owner - new address of implementation
  /// @param name - token clone name
  /// @param id - cloneId of the created clone
  event CloneCreated(
    address indexed clone,
    address indexed owner,
    string name,
    uint256 id
  );

  error FactoryNewImplementationCannotBeAddressZero();
  error FactoryNewImplementationCannotBeEqualOldImplementation();
  error FactoryNewImplementationIsNotContract();
}
