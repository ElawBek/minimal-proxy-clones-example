# Example of a minimal proxy clone

This is an implementation for [EIP 1167](https://eips.ethereum.org/EIPS/eip-1167)

# Installation

1. Clone tis repo:

```shell
git clone https://github.com/ElawBek/minimal-proxy-clones-example.git
```

2. Install NPM packages:

```shell
cd minimal-proxy-clones
npm install
```

# Deployment

localhost:

```shell
npx hardhat node
npx hardhat run scripts/deployFactory.ts
```

custom network (testnets/mainnets):

```shell
npx hardhat run scripts/deployFactory.ts --network yourNetwork
```

## How the scripts/deployFactory.ts script works

1. deploy token contract (implementation)
2. deploy factory contract with constructor args - name and token address (implementation)
3. verify two contracts on scanner
4. create clone
5. mint 1000 tokens to the owner of the clone (just for a test)

# Run tests:

```shell
npx hardhat test
```

# Useful Links

1. [EIP-1167: Minimal Proxy Contract](https://eips.ethereum.org/EIPS/eip-1167)
2. [Deep dive into the Minimal Proxy contract (Openzeppelin blog)](https://blog.openzeppelin.com/deep-dive-into-the-minimal-proxy-contract/)
3. [Non Upgradeable Proxies with EIP1167 (Openzeppelin blog)](https://blog.openzeppelin.com/the-state-of-smart-contract-upgrades/#minimal-proxies)
