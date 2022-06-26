import { expect } from "chai";
import { ethers } from "hardhat";

import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber, constants } from "ethers";
import { id, parseEther } from "ethers/lib/utils";

import {
  ClonesTokenFactory,
  ClonesTokenFactory__factory,
  TestToken,
  TestToken__factory,
} from "../typechain-types";

describe("Minimal proxy - clones", () => {
  let owner: SignerWithAddress;
  let alice: SignerWithAddress;

  let factory: ClonesTokenFactory;

  let tokenOneImpl: TestToken;
  let tokenTwoImpl: TestToken;

  let clone1: TestToken;
  let clone2: TestToken;
  let clone3: TestToken;

  beforeEach(async () => {
    [owner, alice] = await ethers.getSigners();

    tokenOneImpl = await new TestToken__factory(owner).deploy();
    tokenTwoImpl = await new TestToken__factory(owner).deploy();

    factory = await new ClonesTokenFactory__factory(owner).deploy(
      "ClonesTokenFactory",
      tokenOneImpl.address
    );
  });

  describe("Deploy", () => {
    it("Factory variables", async () => {
      expect([
        // factory owner
        await factory.owner(),
        // current implementation
        await factory.implementation(),
        // factory name
        await factory.name(),
        // number of clones of the current implementation
        await factory.getNumberClonesOfImplementation(tokenOneImpl.address),
      ]).to.deep.eq([
        owner.address,
        tokenOneImpl.address,
        "ClonesTokenFactory",
        constants.Zero, // 0
      ]);
    });

    it("Initialization of implementation contracts should return an error", async () => {
      await expect(tokenOneImpl.initialize("Test", "TST")).to.revertedWith(
        "Initializable: contract is already initialized"
      );

      await expect(tokenTwoImpl.initialize("Test", "TST")).to.revertedWith(
        "Initializable: contract is already initialized"
      );
    });
  });

  describe("changeImplementation function", () => {
    it("A change by a non-owner should cause an error", async () => {
      await expect(
        factory.connect(alice).changeImplementation(tokenTwoImpl.address)
      ).to.revertedWith("Ownable: caller is not the owner");
    });

    it("Changing to not-contract should return the error", async () => {
      await expect(factory.changeImplementation(alice.address)).to.revertedWith(
        "FactoryNewImplementationIsNotContract()"
      );
    });

    it("Changing to old implementation should return the error", async () => {
      await expect(
        factory.changeImplementation(tokenOneImpl.address)
      ).to.revertedWith(
        "FactoryNewImplementationCannotBeEqualOldImplementation()"
      );
    });

    it("Success changing implementation should emit 'ImplementationChanged' event", async () => {
      await expect(factory.changeImplementation(tokenTwoImpl.address))
        .to.emit(factory, "ImplementationChanged")
        .withArgs(tokenOneImpl.address, tokenTwoImpl.address);

      expect(await factory.implementation()).to.eq(tokenTwoImpl.address);
    });
  });

  describe("createClone function", () => {
    it("Creating a clone should emit 'CloneCreated' event", async () => {
      await expect(
        factory.connect(alice).createClone("Clone1", "CLN1")
      ).to.emit(factory, "CloneCreated");

      expect(
        await factory.getNumberClonesOfImplementation(tokenOneImpl.address)
      ).to.eq(constants.One);
    });

    it("Check the clone's functionality", async () => {
      await factory.connect(alice).createClone("Clone1", "CLN1");

      const clone1Address = await factory.getClone(tokenOneImpl.address, 1);

      clone1 = new TestToken__factory(alice).attach(clone1Address);

      expect([
        await clone1.name(),
        await clone1.symbol(),
        await clone1.owner(),
      ]).to.deep.eq(["Clone1", "CLN1", alice.address]);

      await clone1.mint(alice.address, parseEther("1000"));

      expect([
        await clone1.totalSupply(),
        await clone1.balanceOf(alice.address),
      ]).to.deep.eq([parseEther("1000"), parseEther("1000")]);
    });
  });

  describe("createCloneDeterministic function", () => {
    it("The predictCloneAddress function should return the same address that is created in createCloneDeterministic", async () => {
      const predictAddress = await factory
        .connect(alice)
        .predictCloneAddress(id("SUPER_STRONG_SALT_1"));

      await expect(
        factory
          .connect(alice)
          .createCloneDeterministic("Clone1", "CLN1", id("SUPER_STRONG_SALT_1"))
      )
        .to.emit(factory, "CloneCreated")
        .withArgs(predictAddress, alice.address, "Clone1", constants.One);

      expect(await factory.getClone(tokenOneImpl.address, constants.One)).to.eq(
        predictAddress
      );
    });
  });

  describe("Full cycle of app", () => {
    beforeEach(async () => {
      await factory.createClone("Clone1", "CLN1");
      await factory.connect(alice).createClone("Clone2", "CLN2");

      // change implementation to TokenTwo
      await factory.changeImplementation(tokenTwoImpl.address);

      // Create one clone of TokenTwo
      await factory.createClone("Clone3", "CLN3");
    });

    it("Find clones", async () => {
      expect([
        await factory.getNumberClonesOfImplementation(tokenOneImpl.address),
        await factory.getNumberClonesOfImplementation(tokenTwoImpl.address),
      ]).to.deep.eq([BigNumber.from(2), BigNumber.from(1)]);

      // find clones
      const clone1Addr = await factory.getClone(tokenOneImpl.address, 1);
      const clone2Addr = await factory.getClone(tokenOneImpl.address, 2);
      const clone3Addr = await factory.getClone(tokenTwoImpl.address, 1);

      // attach clones to contracts
      clone1 = new TestToken__factory(owner).attach(clone1Addr);
      clone2 = new TestToken__factory(alice).attach(clone2Addr);
      clone3 = new TestToken__factory(owner).attach(clone3Addr);

      // check clone1
      expect([
        await clone1.name(),
        await clone1.symbol(),
        await clone1.owner(),
      ]).to.deep.eq(["Clone1", "CLN1", owner.address]);

      // check clone2
      expect([
        await clone2.name(),
        await clone2.symbol(),
        await clone2.owner(),
      ]).to.deep.eq(["Clone2", "CLN2", alice.address]);

      // check clone3
      expect([
        await clone3.name(),
        await clone3.symbol(),
        await clone3.owner(),
      ]).to.deep.eq(["Clone3", "CLN3", owner.address]);
    });

    it("Token functionality in clones", async () => {
      // find clones
      const clone1Addr = await factory.getClone(tokenOneImpl.address, 1);
      const clone3Addr = await factory.getClone(tokenTwoImpl.address, 1);

      // attach clones to contracts
      clone1 = new TestToken__factory(owner).attach(clone1Addr);
      clone3 = new TestToken__factory(owner).attach(clone3Addr);

      await expect(() =>
        clone1.mint(owner.address, parseEther("1000"))
      ).to.changeTokenBalance(clone1, owner, parseEther("1000"));

      await expect(() =>
        clone3.mint(alice.address, parseEther("1000"))
      ).to.changeTokenBalance(clone3, alice, parseEther("1000"));

      await clone3.connect(alice).transfer(owner.address, parseEther("250"));
      await clone1.transfer(alice.address, parseEther("333"));

      expect([
        await clone1.balanceOf(owner.address),
        await clone1.balanceOf(alice.address),
        await clone3.balanceOf(owner.address),
        await clone3.balanceOf(alice.address),
      ]).to.deep.eq([
        parseEther("667"),
        parseEther("333"),
        parseEther("250"),
        parseEther("750"),
      ]);
    });
  });
});
