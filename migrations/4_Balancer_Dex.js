const BDex = artifacts.require("BalancerDex");

module.exports = function (deployer) {
  deployer.deploy(BDex);
};
