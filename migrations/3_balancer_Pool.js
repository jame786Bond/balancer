const BPool = artifacts.require("BalancerPool");

module.exports = function (deployer) {
  deployer.deploy(BPool);
};