const { assert } = require("chai");

const BDex = artifacts.require('./BalancerDex');
const BFactory = artifacts.require('./BalancerFactory');
const BPool = artifacts.require('./BalancerPool');
const BalancerToken =artifacts.require('./BalancerToken');

// 1] Depolyed Successfully
//         | ---------Balancer token Deployed Successfully
//         | ---------Balancer Factory Deployed Succesfully
//         | ---------Balancer Dex Deployed Successfully   
//         | --------- Balancer Pool Created Successfully
// 2] Functions Deployed Successfully
//         | ---------SetSpotPrice Successfully 
//         | ---------getSpotPriceSansFree Succesfully
//         | ---------JoinPool Successfully   
//         | --------- ExitPool Successfully 
// 3] Creation of Pool Successfully
//         | ---------minting Tokens Successfully 
//         | ---------Approved Tokens for Pool Succesfully
//         | ---------Created Pool Successfully
// 4] Swaping Successfully
//         | ---------swapExactAmountIn Successfully 
//         | ---------swapExactAmountOut Succesfully


contract ('BalancerPool',async(accounts) => {
    let pool;
    let BPOOL;
    let factory;
    let dex;
    let token1;
    let token2;
    let BToken;
    let DEX;
    let FACTORY;
    let BTOKEN;
    let TOKEN1;
    let TOKEN2;

    const { toWei } =web3.utils;
    const {fromWei } =web3.utils;
    before(async()=>{
        dex = await BDex.deployed();
        factory = await BFactory.deployed();
        BToken = await BalancerToken.deployed();
        token1 = await BalancerToken.new();
        token2 = await BalancerToken.new();
        FACTORY = await factory.address;
        BTOKEN = await BToken.address;
        TOKEN1 = await token1.address;
        TOKEN2 = await token2.address;

        await token1.mint(accounts[0], '1000000000000000000');
        await token2.mint(accounts[0], '1000000000000000000');

        await token1.mint(accounts[1], '1000000000000000000');
        await token2.mint(accounts[1], '1000000000000000000');

        await token1.mint(accounts[2], '1000000000000000000');
        await token2.mint(accounts[2], '1000000000000000000');
    })

    describe('1] Deploying Contracts',async() =>{
        it('Balance Token Deployed Successfully', async()=>{
            const address =await BToken.address
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
          })
          it('Balancer Factory Deployed Successfully', async()=>{
            const address =await factory.address
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
          })
          it('Balancer Dex Deployed Successfully', async()=>{
            const address =await factory.address
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
          })
        })

    describe('Creation of Pool',async() =>{

        it('Minted 10000000000000000000 tokens to accounts[0] Successfully',async()=>{
            await token1.mint(accounts[0], '10000000000000000000');
            await token2.mint(accounts[0], '10000000000000000000');
        })

        it('Approved 10000000000000000000 tokens to dex address from accounts[0] Successfully',async()=>{
            await token1.approve(dex.address,'10000000000000000000');
            await token2.approve(dex.address,'10000000000000000000');
        })

        it('Createing Pool with token1 and token2 Successfully',async() =>{
        BPOOl = await dex.createPool.call([[TOKEN1,'1000000000000000000','25000000000000000000'],[TOKEN2,'1000000000000000000','25000000000000000000']],FACTORY,0);
        console.log(BPOOL);
    })

    })

    // describe('functions',async()=>{
    //     it('getSpotPrice Successfully',async()=>{
    //        await dex.getSpotPrice(BPOOL,TOKEN1,TOKEN2);
    //     })
    // })
})