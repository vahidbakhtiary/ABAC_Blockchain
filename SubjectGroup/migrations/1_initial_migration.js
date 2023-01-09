const SubjectGroup = artifacts.require("SubjectContract");

module.exports = function (deployer) {
  deployer.deploy(SubjectGroup);
};
