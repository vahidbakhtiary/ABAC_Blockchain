const APSC = artifacts.require("APSC");
const SRMC = artifacts.require("SRMC");

module.exports = function(deployer) {   
  deployer.deploy(APSC);
  deployer.deploy(SRMC);
};
