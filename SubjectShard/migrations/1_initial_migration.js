const APMC = artifacts.require("APMC");
const SAMC = artifacts.require("SAMC");

module.exports = function(deployer) {   
  deployer.deploy(SAMC);
  deployer.deploy(APMC , SAMC.address);
};
