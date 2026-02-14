const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("SecureLottery", function () {
  let lottery;
  let owner, player1, player2, player3;

  beforeEach(async function () {
    [owner, player1, player2, player3] = await ethers.getSigners();
    const SecureLottery = await ethers.getContractFactory("SecureLottery");
    lottery = await SecureLottery.deploy();
  });

  it("Should allow players to enter", async function () {
    await lottery.connect(player1).enter({ value: ethers.parseEther("0.02") });
    expect(await lottery.getPlayerCount()).to.equal(1);
  });

  it("Should FAIL if entry amount is too low", async function () {
    await expect(
      lottery.connect(player1).enter({ value: ethers.parseEther("0.001") })
    ).to.be.revertedWith("Minimum entry is 0.01 ETH");
  });

  it("Should FAIL if winner is selected before 24 hours", async function () {
    await lottery.connect(player1).enter({ value: ethers.parseEther("1.0") });
    await lottery.connect(player2).enter({ value: ethers.parseEther("1.0") });
    await lottery.connect(player3).enter({ value: ethers.parseEther("1.0") });
    await expect(
      lottery.selectWinner()
    ).to.be.revertedWith("Lottery must run for 24 hours");
  });
});