const { assert } = require("chai");

const BDex = artifacts.require('./BalancerDex');
const BFacorty = artifacts.require('./BalancerFactory');
const BPool = artifacts.require('./Balancerpool');
const BalancerToken =artifacts.require('./BalancerToken');


// 1] Depolyed Successfully
//         | ---------Balancer token Deployed Successfully
//         | ---------Balancer Factory Deployed Succesfully
//         | ---------Balancer Dex Deployed Successfully   
// 1] Functions Deployed Successfully
//         | ---------Created Pool Successfully 
//         | ---------SetBLabs Succesfully
//         | ---------Collected Successfully Successfully   
//         | --------- isBalancerPool Successfully
// 


contract ('BalancerFactory',async(accounts) => {

    let POOL;
    let pool;
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
    before(async()=>{
        dex = await BDex.deployed();
        factory = await BFacorty.deployed();
        BToken = await BalancerToken.deployed();
        token1 = await BalancerToken.new();
        token2 = await BalancerToken.new();
        FACTORY = await factory.address;
        BTOKEN = await BToken.address;
        TOKEN1 = await token1.address;
        TOKEN2 = await token2.address;
        //  POOL = await factory.newBPool.call(accounts[0]);
        // await factory.newBPool();
        //  const pool = await BPool.at(POOL);
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

    describe('Functions', async() =>{
        it('Created Pool Successfully', async() =>{
            POOL = await factory.newBPool.call(accounts[0]);
            await factory.newBPool(accounts[0]);
            console.log(POOL);
            pool = await BPool.at(POOL);  
            const address =await POOL
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
            })
        
          it('setBLabs Successfully',async() =>{
              await factory.setBLabs(accounts[0]);
              const BLabs = await factory.getBLabs.call();
              assert.strictEqual(BLabs,accounts[0]);
          })

          it('collected Successfully',async() =>{
              await factory.collect(POOL);
          })
    })

})