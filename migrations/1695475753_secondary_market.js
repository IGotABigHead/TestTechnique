const SecondaryMarket = artifacts.require("SecondaryMarket");

module.exports = function (deployer) {
  deployer.deploy(SecondaryMarket)
};
