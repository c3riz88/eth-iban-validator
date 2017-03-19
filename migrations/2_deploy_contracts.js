var IBANValidator = artifacts.require("./IBANValidator.sol");

module.exports = function(deployer) {
  deployer.deploy(IBANValidator);
};
