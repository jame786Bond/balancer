const BFacorty = artifacts.require("BalancerFactory");

module.exports = function (deployer) {
  deployer.deploy(BFacorty);
};
