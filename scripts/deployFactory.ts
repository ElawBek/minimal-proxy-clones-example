import { ethers, run } from "hardhat";

import { parseEther } from "ethers/lib/utils";

import {
  ClonesTokenFactory__factory,
  TestToken__factory,
} from "../typechain-types";

async function main() {
  const [signer] = await ethers.getSigners();

  const token = await new TestToken__factory(signer).deploy();
  await token.deployed();

  const factory = await new ClonesTokenFactory__factory(signer).deploy(
    "ClonesTokenFactory",
    token.address
  );
  await factory.deployed();

  await run("verify:verify", {
    address: token.address,
    contract: "contracts/Token.sol:TestToken",
  });

  await run("verify:verify", {
    address: factory.address,
    contract: "contracts/ClonesTokenFactory.sol:ClonesTokenFactory",
    constructorArguments: ["ClonesTokenFactory", token.address],
  });

  let tx = await factory.createClone("TestClone1", "TK1");
  await tx.wait();

  const cloneAddr = await factory.getClone(token.address, 1);

  const clone = new TestToken__factory(signer).attach(cloneAddr);

  tx = await clone.mint(signer.address, parseEther("1000"));
  await tx.wait();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
