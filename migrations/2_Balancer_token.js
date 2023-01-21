const BToken = artifacts.require("BalancerToken");

module.exports = function (deployer) {
  deployer.deploy(BToken);
};
