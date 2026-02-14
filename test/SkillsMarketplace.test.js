const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SkillsMarketplace", function () {
  let marketplace;
  let owner, employer, worker, randomUser;

  beforeEach(async function () {
    [owner, employer, worker, randomUser] = await ethers.getSigners();
    const SkillsMarketplace = await ethers.getContractFactory("SkillsMarketplace");
    marketplace = await SkillsMarketplace.deploy();
  });

  it("Should register a worker successfully", async function () {
    await marketplace.connect(worker).registerWorker("Solidity");
    const skill = await marketplace.workerSkills(worker.address);
    expect(skill).to.equal("Solidity");
  });

  it("Should FAIL if worker tries to apply without registering", async function () {
    await marketplace.connect(employer).postGig("Build DAO", "Solidity", { value: ethers.parseEther("1.0") });
 
    await expect(
      marketplace.connect(randomUser).applyForGig(1)
    ).to.be.revertedWith("Worker not registered"); 
  });

 
  it("Should FAIL if employer tries to pay before work is submitted", async function () {
    await marketplace.connect(worker).registerWorker("Solidity");
    await marketplace.connect(employer).postGig("Build DAO", "Solidity", { value: ethers.parseEther("1.0") });
    await marketplace.connect(worker).applyForGig(1);
    
    await expect(
      marketplace.connect(employer).approveAndPay(1, worker.address)
    ).to.be.revertedWith("Work not submitted yet");
  });
});