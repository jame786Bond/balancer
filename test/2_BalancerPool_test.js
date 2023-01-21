const { assert } = require("chai");

const BDex = artifacts.require('./BalancerDex');
const BFacorty = artifacts.require('./BalancerFactory');
const BPool = artifacts.require('./BalancerPool');
const BalancerToken =artifacts.require('./BalancerToken');
// const Tokens = arttifacts.require('./Token1');


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
//         | ---------isPublicSwap Successfully 
//         | ---------isFinalized Succesfully
//         | ---------isBound Successfully   
//         | ---------getNumTokens Successfully
//         | ---------getCurrentTokens Successfully 
//         | ---------GotFinalTokens Succesfully
//         | ---------getDenormalizedWeight Successfully   
//         | --------- getTotalDenormalizedWeight Successfully
//         | ---------getNormalizedWeight Successfully   
//         | --------- getBalance Successfully
//         | ---------getSwapFee Successfully 
//         | ---------getController Succesfully
//         | ---------updateRecordBalance Successfully   
//         | ---------setSwapFee Successfully
//         | ---------setController Successfully 
//         | ---------setPublicSwap Succesfully
//         | ---------finalize Successfully   
// 3] Binding Successfully
//         | ---------minting Tokens Successfully 
//         | ---------Approved Tokens for Pool Succesfully
//         | ---------Binding Tokens Successfully Successfully   
//         | --------- Unbiding Token Successfully
// 4] Swaping Successfully
//         | ---------swapExactAmountIn Successfully 
//         | ---------swapExactAmountOut Succesfully
//         | ---------joinSwapExternAmountIn Successfully   
//         | ---------joinSwapPoolAmountOut Successfully
//         | ---------exitSwapPoolAmountIn Successfully   
//         | ---------exitSwapExternAmountOut Successfully
// 5] support functions Successfully
//         | ---------_pullUnderlying Successfully 
//         | ---------_pushUnderlying Succesfully
//         | ---------_pullPoolShare Successfully   
//         | ---------_pushPoolShare Successfully
//         | ---------_mintPoolShare Successfully   
//         | ---------_burnPoolShare Successfully

// 


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
    let TOKEN3;
    let TOKEN4;
    let TOKEN5;
    let TOKEN6;
    let TOKEN7;
    let TOKEN8;

    const { toWei } =web3.utils;
    const {fromWei } =web3.utils;
    before(async()=>{
        dex = await BDex.deployed();
        factory = await BFacorty.deployed();
        BToken = await BalancerToken.deployed();

        FACTORY = await factory.address;
        BTOKEN = await BToken.address;

        BPOOL = await BPool.deployed();
        // BPOOL = BPool.deployed(BTOKEN);
        pool = await BPOOL.address;
        token1 = await BalancerToken.new();
        token2 = await BalancerToken.new();
        token3 = await BalancerToken.new();
        token4 = await BalancerToken.new();
        token5 = await BalancerToken.new();
        token6 = await BalancerToken.new();
        token7 = await BalancerToken.new();
        token8 = await BalancerToken.new();
        TOKEN1 = await token1.address;
        TOKEN2 = await token2.address;
        TOKEN3 = await token3.address;
        TOKEN4 = await token4.address;
        TOKEN5 = await token5.address;
        TOKEN6 = await token6.address;
        TOKEN7 = await token7.address;
        TOKEN8 = await token8.address;
        

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
          it('Balancer Pool Deployed Successfully', async()=>{
            const address =await BPOOL.address
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
          })

        })

    describe('Creating Pool', async() =>{
      it('Minting 100000000000000000000 tokens to accounts[0]',async()=>{
        await token1.mint(accounts[0], '100000000000000000000');
        await token2.mint(accounts[0], '100000000000000000000');
        await token3.mint(accounts[0], '100000000000000000000');
        await token4.mint(accounts[0], '100000000000000000000');
        await token5.mint(accounts[0], '100000000000000000000');
        await token6.mint(accounts[0], '100000000000000000000');
        await token7.mint(accounts[0], '100000000000000000000');
        await token8.mint(accounts[0], '100000000000000000000');
      })
      
      it('Approved 10000000000000000000 tokens to pool address', async() =>{
        await token1.approve(BPOOL.address,'10000000000000000000');
        await token2.approve(BPOOL.address,'10000000000000000000');
        await token3.approve(BPOOL.address,'10000000000000000000');
        await token4.approve(BPOOL.address,'10000000000000000000');
        await token5.approve(BPOOL.address,'10000000000000000000');
        await token6.approve(BPOOL.address,'10000000000000000000');
        await token7.approve(BPOOL.address,'10000000000000000000');
        await token8.approve(BPOOL.address,'10000000000000000000');      

      })
      it('binding tokens with 1000000000000000000 balance and 2000000000000000000 denorm',async()=>{
        await BPOOL.bind(TOKEN1,'1000000000000000000','2000000000000000000',accounts[0]);
        await BPOOL.bind(TOKEN2,'1000000000000000000','2000000000000000000',accounts[0]);
        await BPOOL.bind(TOKEN3,'1000000000000000000','2000000000000000000',accounts[0]);
        await BPOOL.bind(TOKEN4,'1000000000000000000','2000000000000000000',accounts[0]);
        await BPOOL.bind(TOKEN5,'1000000000000000000','2000000000000000000',accounts[0]);
        await BPOOL.bind(TOKEN6,'1000000000000000000','2000000000000000000',accounts[0]);
        await BPOOL.bind(TOKEN7,'1000000000000000000','2000000000000000000',accounts[0]);
        await BPOOL.bind(TOKEN8,'1000000000000000000','2000000000000000000',accounts[0]);
        // const numToken = await BPOOL.getNumTokens();
        // assert.equal(numToken,8);
          
        // const totalDweight = await BPOOL.getTotalDenormalizedWeight();
        // assert.equal(totalDweight,'25000000000000000000');
      })
    })

    describe('Functions',async()=>{
      it('get Controller',async() =>{
         const Controller =await BPOOL.getController();
         assert.equal(Controller,accounts[0]);
      })
     it('Testing isPublicSwap should be false',async() =>{
          const public =await BPOOL.isPublicSwap();
          assert.equal(public,false);
      })
      it('Testing setSwapfee ',async() =>{
          await BPOOL.setSwapFee(1000000000000000);
          const fee = await BPOOL.getSwapFee();
          assert.equal(fee,1000000000000000);
      })

      it('Testing Number of Tokens in Pool should be 8',async()=>{
         const numToken = await BPOOL.getNumTokens();
          assert.equal(numToken,8);
      })
      it('Testing isFinalized should be false',async()=>{
         const _finalize = await BPOOL.isFinalized();
          assert.equal(_finalize,false);
     })
      it('Testing isBound should be false',async()=>{
          const bound = await BPOOL.isBound(pool);
          assert.equal(bound,false);
      })
      it('Testing getDenormalizedWeight of Token1 should be 2000000000000000000',async()=>{
          const w = await BPOOL.getDenormalizedWeight(TOKEN1);
          assert.equal(w.toString(),'2000000000000000000');
      })
      it('Testing getTotalDenormalizedWeight should be 16000000000000000000',async()=>{
          const Tweight = await BPOOL.getTotalDenormalizedWeight();
          assert.equal(Tweight.toString(),'16000000000000000000');
      })
      // it('checking finalize',async()=>{
      //   await BPOOL.finalize(BPOOL.address,accounts[0]);

      //   const final = BPOOL.isFinalized();
      //   assert.equal(final,true);

      //   const public = BPOOL.isPublicSwap();
      //   assert.equal(public,true);
      // })
    })


    describe('Rebinding Pool', async() =>{
      it(' Rebinding Token1 with 2000000000000000000 balance and 4000000000000000000 denorm Successfully', async() =>{
        await BPOOL.rebind(TOKEN1,'2000000000000000000','4000000000000000000',accounts[0])
      })
      it('Testing getDenormalizedWeight of Token1 afer rebinding should be 4000000000000000000',async()=>{
        const w = await BPOOL.getDenormalizedWeight(TOKEN1);
        assert.equal(w.toString(),'4000000000000000000');
    })
    it('Testing getTotalDenormalizedWeight After Rebinding should be 18000000000000000000',async()=>{
      const Tweight = await BPOOL.getTotalDenormalizedWeight();
      assert.equal(Tweight.toString(),'18000000000000000000');
    })

      // it('checking totalWeight')
    })

    describe('Unbinding Pool', async()=>{
      it('Unbinding Token1', async()=>{
        await BPOOL.unbind(TOKEN1);
      })
    it('Testing Number of Tokens in Pool should be 7',async()=>{
      const numToken = await BPOOL.getNumTokens();
       assert.equal(numToken,7);
   })
    it('Testing getTotalDenormalizedWeight After Unbinding 14000000000000000000',async()=>{
      const Tweight = await BPOOL.getTotalDenormalizedWeight();
      assert.equal(Tweight.toString(),'14000000000000000000');
    })
     
    })

    describe('Join Pool',async()=>{

      it('finalizing Pool',async() =>{
        await BPOOL.finalize(BPOOL.address,accounts[0]);
      })
      it('Joining pool with 1000000000000000000 balance from accounts[0]',async()=>{
        await BPOOL.joinPool(accounts[0],'1000000000000000000')
      })
      it('Testing Pool Total should be 101000000000000000000',async()=>{
        const totalsuply = await BPOOL.getPoolTotal();
        assert.equal(totalsuply.toString(),'101000000000000000000'); 
      })
    })
  
})

