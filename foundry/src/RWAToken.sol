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
    IIdentityRegistry public identityRegistry;
    address treasury;

    event NewCompliance(address _newCompliance);
    event NewIdentityRegistry(address _identityRegistry);
    event ForcedTransferOfUser(address _user, uint256 value);

    error ComplianceNotSet();
    error BadCompliance(address from, address to, uint256 value);
    error ZeroAddress();
    error InvalidTreasuryAddress();
    // definir supply, valeur de 1 token.

    constructor() {
        _disableInitializers();
    }

    function initialize(string memory name, string memory symbol, address _treasury, uint256 _totalSupply, ICompliance _compliance, IIdentityRegistry _identityRegistry) public initializer
    {
        if (_treasury == address(0)) revert InvalidTreasuryAddress();
        __Ownable_init(msg.sender);
        __Pausable_init();
        __ERC20_init(name, symbol);
        setCompliance(_compliance);
        setIdentityRegistry(_identityRegistry);
        treasury = _treasury;
        _mint(treasury, _totalSupply); // treasury = multisig
    }

    function setIdentityRegistry(IIdentityRegistry newIdentityRegistry) public onlyOwner
    {
        if(address(newIdentityRegistry) == address(0)) revert ZeroAddress();
        identityRegistry = newIdentityRegistry;
        emit NewIdentityRegistry(address(identityRegistry));
    }

    function setCompliance(ICompliance newCompliance) public onlyOwner
    {
        if(address(newCompliance) == address(0)) revert ZeroAddress();
        compliance = newCompliance;
        emit NewCompliance(address(compliance));
    }

    function burn(address _treasury, uint256 value) external onlyOwner{
        _burn(_treasury, value);
    }

    function pause() external  onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function forceTransfer(address _from, address _to, uint256 value) public onlyOwner {
        require(_from != address(0) && _to == treasury);
        require(balanceOf(_from) >= value);
        super._update(_from, _to, value);
    }

    function enforceMaxLimits() public onlyOwner {
        address [] memory tokenHolders = identityRegistry.tokenHolders();
        address user;
        uint256 userBalance;
        uint256 excess;
        uint256 maxBalance = compliance.getMaxSupplyPerUser();
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            user = tokenHolders[i];
            userBalance = balanceOf(user);
            if(userBalance > maxBalance)
            {
                excess = userBalance - maxBalance;
                forceTransfer(user, treasury, excess);
                emit ForcedTransferOfUser(user, excess);
            }
         }
    }

    function _update(address from, address to, uint256 value) internal override whenNotPaused {
        if(address(compliance) == address (0)) revert ComplianceNotSet();
        if(!compliance.canTransfer(from, to, value)) revert BadCompliance(from, to, value);
        super._update(from,to,value);
        identityRegistry.registerUsersTokens(to, address(this));
    }

}