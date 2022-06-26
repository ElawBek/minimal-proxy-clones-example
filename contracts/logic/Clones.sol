// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

/**
 * @dev Just copied from openzeppelin
 *
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 */
library Clones {
  // || copy link ||
  // https://www.evm.codes/playground?unit=Wei&codeType=Mnemonic&code='_Pjnstructorkg602d806WaQ981f336gQ7ggQ6g7LVXimplementationR%20addUssY20ZSSSS~60zshlM14NXfutuUTtk5af4g82803e90g91602b57fd5bfLyWM28NvcUate%20newTct~37MWzcUateOOO'~Y1Zz%5CnyWWWWvzmstoUO_q22222kRjdeY32Zj%20coQd_%2F%2F%20Z%200xYzpushXvP%20W00M80UreTjntraSqqR%22sQg3PloadOzzNzaddMV~L3yyy%01LMNOPQRSTUVWXYZ_gjkqvyz~_
  /**
   * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
   *
   * This function uses the create opcode, which should never revert.
   */
  function clone(address implementation) internal returns (address instance) {
    assembly {
      let ptr := mload(0x40)
      mstore(
        ptr,
        0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
      )
      mstore(add(ptr, 0x14), shl(0x60, implementation))
      mstore(
        add(ptr, 0x28),
        0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
      )
      instance := create(0, ptr, 0x37)
    }
    require(instance != address(0), "ERC1167: create failed");
  }

  // || copy link ||
  // https://www.evm.codes/playground?unit=Wei&codeType=Mnemonic&code='_PjnstructorXg602d806VaQ981f336gQ7ggQ6g7LUWimplementationS%20addressY20ZTTTT~60zshlM14OWfuturejntratX5af4g82803e90g91602b57fd5bfLwVM28OvsaltkNNNN~37MVzcreate2z'~Y1Zz%5CnyRRRRwVVVVvzmstorezz_q22222kY32Zj%20coQd_%2F%2F%20Z%200xYzpushXSjdekWvP%20V00M80TqqS%22sRFFQg3PloadOzaddNyyMU~L3www%01LMNOPQRSTUVWXYZ_gjkqvwyz~_
  /**
   * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
   *
   * This function uses the create2 opcode and a `salt` to deterministically deploy
   * the clone. Using the same `implementation` and `salt` multiple time will revert, since
   * the clones cannot be deployed twice at the same address.
   */
  function cloneDeterministic(address implementation, bytes32 salt)
    internal
    returns (address instance)
  {
    assembly {
      let ptr := mload(0x40)
      mstore(
        ptr,
        0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
      )
      mstore(add(ptr, 0x14), shl(0x60, implementation))
      mstore(
        add(ptr, 0x28),
        0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
      )
      instance := create2(0, ptr, 0x37, salt)
    }
    require(instance != address(0), "ERC1167: create2 failed");
  }

  // || copy link ||
  // https://www.evm.codes/playground?unit=Wei&codeType=Mnemonic&code='SPgnstrucKVjU602dL6MaE981f336UE7UUE6U7.~LZP%20implementationH_XQ14zPWtVj5af4U82L3e90U91602b57fd5bf.kMY28zdeployerBfacKy%7DXQ38zsaltjAAAAY4czhaTWctV~37~LCY6czcomputeBlast%2020%20bytes%20of%20haT%7D~55Y37%20wJCDDD'~O1RzwJZw%5CnvIIIIqGGGGkMMMMjO32Rg%20coNJressZwmsKeDSY~L~XO20RvvvvW%20futuregntraVHgdeEdTshS%2F%2F%20R%200xQv~60wTlYPloadOwpuTN_%20M00L80KtorJaddI22H%22sGFFEU3DwwCwTa3BN%7BAqq.3kkk%01.ABCDEGHIJKLMNOPQRSTUVWXYZ_gjkqvwz~_
  /**
   * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
   */
  function predictDeterministicAddress(
    address implementation,
    bytes32 salt,
    address deployer
  ) internal pure returns (address predicted) {
    assembly {
      let ptr := mload(0x40)
      mstore(
        ptr,
        0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
      )
      mstore(add(ptr, 0x14), shl(0x60, implementation))
      mstore(
        add(ptr, 0x28),
        0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000
      )
      mstore(add(ptr, 0x38), shl(0x60, deployer))
      mstore(add(ptr, 0x4c), salt)
      mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
      predicted := keccak256(add(ptr, 0x37), 0x55)
    }
  }

  /**
   * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
   */
  function predictDeterministicAddress(address implementation, bytes32 salt)
    internal
    view
    returns (address predicted)
  {
    return predictDeterministicAddress(implementation, salt, address(this));
  }
}
