// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

import "../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "../lib/openzeppelin-contracts-upgradeable/contracts/utils/PausableUpgradeable.sol";

import "./Interfaces/IIdentityRegistry.sol";
import "./Interfaces/ICompliance.sol";

contract RWAToken is Initializable, ERC20Upgradeable, OwnableUpgradeable, PausableUpgradeable
{
    ICompliance public compliance;
    address treasury;

    event NewCompliance(address _newCompliance);

    error ComplianceNotSet();
    error BadCompliance(address from, address to, uint256 value);
    error ZeroAddress();
    error InvalidTreasuryAddress();
    // definir supply, valeur de 1 token.

    constructor() {
        _disableInitializers();
    }

    function initialize(string memory name, string memory symbol, address _treasury, uint256 _totalSupply, ICompliance _compliance) public initializer
    {
        if (_treasury == address(0)) revert InvalidTreasuryAddress();
        __Ownable_init(msg.sender);
        __Pausable_init();
        __ERC20_init(name, symbol);
        setCompliance(_compliance);
        treasury = _treasury;
        _mint(treasury, _totalSupply); // treasury = multisig
    }

    function setCompliance(ICompliance newCompliance) public onlyOwner
    {
        if(address(newCompliance) == address(0)) revert ZeroAddress();
        compliance = newCompliance;
        emit NewCompliance(address(compliance));
    }

    function burn(address treasury, uint256 value) external onlyOwner{
        _burn(treasury, value);
    }

    function pause() external  onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function forceTransfer(address _from, address _to, uint256 value) external onlyOwner {
        require(_from != address(0) && _to == treasury);
        require(balanceOf(_from) >= value);
        super._update(_from, _to, value);
    }

    function _update(address from, address to, uint256 value) internal override whenNotPaused {
        if(address(compliance) == address (0)) revert ComplianceNotSet();
        if(!compliance.canTransfer(from, to, value)) revert BadCompliance(from, to, value);
        super._update(from,to,value);
    }

}