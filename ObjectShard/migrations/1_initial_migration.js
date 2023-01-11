const APMC = artifacts.require("APMC");
const OAMC = artifacts.require("OAMC");

module.exports = function(deployer) {   
  deployer.deploy(OAMC);
  deployer.deploy(APMC , OAMC.address);
};
