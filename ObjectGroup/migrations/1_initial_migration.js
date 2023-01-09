const ObjectContract = artifacts.require("ObjectContract");

module.exports = function (deployer) {
  deployer.deploy(ObjectContract);
};
