// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./logic/Clones.sol";

import "./interfaces/IToken.sol";
import "./interfaces/IClonesTokenfactory.sol";

/**
 * @title ClonesTokenFactory
 * @author Dmitry K. (@elawbek)
 *
 * @dev factory contract to create immutable clones using minimal proxy contracts, also known as "clones"
 * https://eips.ethereum.org/EIPS/eip-1167
 */
contract ClonesTokenFactory is IClonesTokenFactory, Ownable {
  /// @notice current implementation for creating clones
  address public implementation;

  /// @notice mapping clones of each implementation
  /// @dev impl address --> cloneId --> clone address
  mapping(address => mapping(uint256 => address)) private clones;

  /// @notice number of clones per implementation
  /// @dev impl address --> number of clones
  mapping(address => uint256) private numberOfImplClones;

  /**
   * @notice set the first implementation address for the subsequent creation of clones
   * @param _impl - the new implementation address
   *
   * @dev the new implementation must be a deployed contract
   * emit `ImplementationChanged` event
   */
  constructor(address _impl) {
    enforceHasContractCode(_impl);

    implementation = _impl;

    emit ImplementationChanged(address(0), _impl);
  }

  function getNumberClonesOfImplementation(address _impl)
    external
    view
    returns (uint256 num_)
  {
    num_ = numberOfImplClones[_impl];
  }

  function getClone(address _impl, uint256 _id)
    external
    view
    returns (address clone_)
  {
    clone_ = clones[_impl][_id];
  }

  /**
   * @notice set the new implementation address to the factory
   * @param _newImpl - the new implementation address
   *
   * @dev the new implementation must be a deployed contract
   * and can't be equal to the old implementation
   *
   * only owner of factory can execute this function
   * emit `ImplementationChanged` event
   */
  function changeImplementation(address _newImpl) external onlyOwner {
    enforceHasContractCode(_newImpl);

    address _oldImpl = implementation; // gas saving

    if (_newImpl == _oldImpl) {
      revert FactoryNewImplementationCannotBeEqualOldImplementation();
    }

    implementation = _newImpl;

    emit ImplementationChanged(_oldImpl, _newImpl);
  }

  /**
   * @notice create clone of implementation contract by CREATE opcode
   * @param _name - name of the clone token
   * @param _symbol - symbol of the clone token
   *
   * @dev emit `CloneCreated` event
   */
  function createClone(string calldata _name, string calldata _symbol)
    external
  {
    address impl = implementation;

    unchecked {
      numberOfImplClones[impl]++;
    }
    uint256 id = numberOfImplClones[impl];

    address newClone = Clones.clone(impl);

    IToken(newClone).initialize(_name, _symbol);
    IToken(newClone).transferOwnership(msg.sender);

    clones[impl][id] = newClone;

    emit CloneCreated(newClone, msg.sender, _name, id);
  }

  /**
   * @notice create clone of implementation contract by CREATE2 opcode
   * @param _name - name of the clone token
   * @param _symbol - symbol of the clone token
   * @param salt - byte32 value to create a unique address
   *
   * @dev emit `CloneCreated` event
   */
  function createCloneDeterministic(
    string calldata _name,
    string calldata _symbol,
    bytes32 salt
  ) external {
    address impl = implementation;

    unchecked {
      numberOfImplClones[impl]++;
    }
    uint256 id = numberOfImplClones[impl];

    address newClone = Clones.cloneDeterministic(implementation, salt);

    IToken(newClone).initialize(_name, _symbol);
    IToken(newClone).transferOwnership(msg.sender);

    clones[impl][id] = newClone;

    emit CloneCreated(newClone, msg.sender, _name, id);
  }

  /**
   * @notice view function to predict the address of the clone that will be created through create2
   * @param salt - byte32 value to create a unique address
   */
  function predictCloneAddress(bytes32 salt)
    external
    view
    returns (address predict_)
  {
    predict_ = Clones.predictDeterministicAddress(implementation, salt);
  }

  function enforceHasContractCode(address _impl) private view {
    uint256 contractSize;
    assembly {
      contractSize := extcodesize(_impl)
    }
    if (contractSize == 0) {
      revert FactoryNewImplementationIsNotContract();
    }
  }
}
