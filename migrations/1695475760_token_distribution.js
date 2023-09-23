const TokenDistribution = artifacts.require("TokenDistribution");

module.exports = function (deployer) {
  deployer.deploy(TokenDistribution)
};
