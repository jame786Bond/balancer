const _Balancer_token = require("../migrations/2_Balancer_token");

const BalancerToken =artifacts.require('./BalancerToken');



// 1] Depolyed Successfully
//         | ---------Balancer token Deployed Successfully
// 2] Functions Deployed Successfully
//         | ---------minting Tokens Successfully 
//         | ---------Approved Tokens for Pool Succesfully
//         | ---------Transfered Successfully Successfully   
//         | ---------TransferdFrom Successfully
// 


contract('BalancerToken',(accounts) =>{
before(async() =>{
  BToken = await BalancerToken.deployed()
})

it('Deploys Successfully', async()=>{
  const address =await BToken.address
  assert.notEqual(address, 0x0)
  assert.notEqual(address, '')
  assert.notEqual(address, null)
  assert.notEqual(address, undefined)
})

it('Checking Informations', async () => {
  const name = await BToken.name.call()
  assert.strictEqual(name, 'Balancer Pool Token')

  // const decimals = await token.decimals.call()
  // assert.strictEqual(decimals.toNumber(), tokenDecimals)

  const symbol = await BToken.symbol.call()
  assert.strictEqual(symbol, 'BPT')
})
it('Minted 100000000 tokens for accounts[0] Successfully', async() =>{
   await BToken.mint(accounts[0],100000000 ,{ from: accounts[ 0 ] })
    const balance = await BToken.balanceOf.call(accounts[0])
    assert.strictEqual(balance.toString(), '100000000')
})

it(' Transfered 10000 tokens to accounts[1] Successfully', async () => {
  await BToken.transfer(accounts[ 1 ], 10000, { from: accounts[ 0 ] })
  const balance = await BToken.balanceOf.call(accounts[ 1 ])
  assert.strictEqual(balance.toNumber(), 10000)
})

it('Approved 1000 tokens to accounts[1] Successfully ', async () => {
  await BToken.approve(accounts[ 1 ], 1000, { from: accounts[ 0 ] })
  const allowance = await BToken.allowance.call(accounts[ 0 ], accounts[ 1 ])
  assert.strictEqual(allowance.toNumber(), 1000)
})


it('TransferedFrom accounts[0] successfully', async () => {
  await BToken.approve(accounts[ 1 ], 100, { from: accounts[ 0 ] })
  const allowance01 = await BToken.allowance.call(accounts[ 0 ], accounts[ 1 ])
  assert.strictEqual(allowance01.toNumber(), 100)

  await BToken.transferFrom(accounts[ 0 ], accounts[ 2 ], 20, { from: accounts[ 1 ] })
  const allowance012 = await BToken.allowance.call(accounts[ 0 ], accounts[ 1 ])
  assert.strictEqual(allowance012.toNumber(), 80)

  const balance2 = await BToken.balanceOf.call(accounts[ 2 ])
  assert.strictEqual(balance2.toNumber(), 20)

  const balance0 = await BToken.balanceOf.call(accounts[ 0 ])
  assert.strictEqual(balance0.toNumber(), 99989980)
})
})



// var Token = artifacts.require("BalancerToken");


// contract('BalancerToken', function(accounts) {
//   it("Chekking Minting and Total Supply", function() {
//     var token;
//     return Token.deployed().then(function(instance){
//      token = instance;
//      return token.mint.call(accounts[0],1000000);
//     }).then(function(result){
//      assert.equal(result.toNumber(), 1000000, 'total supply is wrong');
//     })
//   });
// });

// it("Checking balanceOf", function() {
//     var token;
//     return Token.deployed().then(function(instance){
//       token = instance;
//       return token.balanceOf.call(accounts[0]);
//     }).then(function(result){
//       assert.equal(result.toNumber(), 1000000, 'balance is wrong');
//     })
//   });

//   it("Checking Transfer Function", function() {
//     var token;
//     return Token.deployed().then(function(instance){
//       token = instance;
//       return token.transfer(accounts[1], 500000);
//     }).then(function(){
//       return token.balanceOf.call(accounts[0]);
//     }).then(function(result){
//       assert.equal(result.toNumber(), 500000, 'accounts[0] balance is wrong');
//       return token.balanceOf.call(accounts[1]);
//     }).then(function(result){
//       assert.equal(result.toNumber(), 500000, 'accounts[1] balance is wrong');
//     })
//   });

//   it("checking Approve and allowance function", function() {
//       var token;
//       return Token.deployed().then(function(instance){
//           token= instance;
//           return token.Approve.call(accounts[1],10000);
//       }).then(function(){
//           return token.allowance.call(accounts[0],accounts[1]);
//       }).then(function(result){
//           assert.equal(result.toNumber(),10000, 'Allowance is Wrong');
//       })
//   })

//   it("Checking TransferFrom Function with Approve and allowance function", function() {
//     var token;
//     return Token.deployed().then(function(instance){
//      token = instance;
//      return token.approve(accounts[1], 200000);
//     }).then(function(){
//      return token.allowance.call(accounts[0], accounts[1]);
//     }).then(function(result){
//      assert.equal(result.toNumber(), 200000, 'allowance is wrong');
//      return token.transferFrom(accounts[0], accounts[2], 200000, {from: accounts[1]});
//     }).then(function(result){
//     console.log(result.logs[0].event)
//      return token.balanceOf.call(accounts[0]);
//     }).then(function(result){
//      assert.equal(result.toNumber(), 300000, 'accounts[0] balance is wrong');
//      return token.balanceOf.call(accounts[1]);
//     }).then(function(result){
//      assert.equal(result.toNumber(), 500000, 'accounts[1] balance is wrong');
//      return token.balanceOf.call(accounts[2]);
//     }).then(function(result){
//      assert.equal(result.toNumber(), 200000, 'accounts[2] balance is wrong');
//     })
//   });

// //   it("checking Burn function",function(){
// //       var token;
// //       return Token.deployed().then(function(instance){
// //           token = instance;
// //           return token.burn(accounts[1],1000)
// //       })
// //   }) 

//   it("Checking transfer event", function() {
//     var token;
//     return Token.deployed().then(function(instance){
//       token = instance;
//       return token.transfer(accounts[1], 100000);
//     }).then(function(result){
//       console.log(result.logs[0].event)
//     })
//   });