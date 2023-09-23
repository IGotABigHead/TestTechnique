const RentManagement = artifacts.require("RentManagement");

module.exports = function (deployer) {
  deployer.deploy(RentManagement)
};
