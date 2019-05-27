const Ownable = artifacts.require('Ownable')
const Remittance = artifacts.require('Remittance')
const SafeMath = artifacts.require('SafeMath')
const Stoppable = artifacts.require('Stoppable')

module.exports = function(deployer) {
    deployer.deploy(SafeMath);
    deployer.deploy(Remittance);
}