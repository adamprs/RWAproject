// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "./Interfaces/IIdentityRegistry.sol";
import "./Interfaces/IRWAToken.sol";

contract Compliance is Initializable, OwnableUpgradeable
{
    IIdentityRegistry public identityRegistry;
    IRWAToken public realToken;
    uint256 public maxOwnershipBPS = 1000;

    event IdentityRegistryUpdated(address indexed newIdentityRegistry);
    event RealTokenUpdated(address indexed newRealToken);
    event MaxOwnershipBPSUpdated(uint256 newMaxOwnershipBPS);

    error SenderNotKyc(address _sender);
    error ReceiverNotKyc(address _receiver);
    error ReceiverUpMaxSupply(address _receiver);
    error ZeroAddress();
    error InvalidBPS(uint256 maxOwnershipBPS);
    error UnauthorizedBurn(address _sender);
    error UnauthorizedUser();
    error UserFreezed(address _user);

    constructor() 
    {
        _disableInitializers();
    }

    function initialize(IIdentityRegistry _identityRegistry, IRWAToken _realToken) public initializer {
        __Ownable_init(msg.sender);
        setIdentityRegistry(_identityRegistry);
        setRealToken(_realToken);
    }

    function setIdentityRegistry(IIdentityRegistry _identityRegistry) public onlyOwner {
        if(address(_identityRegistry) == address(0)) revert ZeroAddress();
        identityRegistry = _identityRegistry;
        emit IdentityRegistryUpdated(address(_identityRegistry));
    }

    function getMaxSupplyPerUser() internal view returns (uint256) 
    {
        return (realToken.totalSupply() * maxOwnershipBPS) / 10000;
    }

     function setRealToken(IRWAToken _realToken) public onlyOwner {
        if(address(_realToken) == address(0)) revert ZeroAddress();
        realToken = _realToken;
        emit RealTokenUpdated(address(_realToken));
    }

    function setNewMaxOwnershipBPS(uint256 newMaxOwnershipBPS) public onlyOwner {
        if(newMaxOwnershipBPS > 10000) revert InvalidBPS(newMaxOwnershipBPS);
        if(newMaxOwnershipBPS == 0) revert InvalidBPS(newMaxOwnershipBPS);
         maxOwnershipBPS = newMaxOwnershipBPS;
        emit MaxOwnershipBPSUpdated(newMaxOwnershipBPS);
        realToken.enforceMaxLimits();
    }


    //Tracker le nombre d'investisseur sur un bien !

    function canTransfer(address _sender, address _receiver, uint256 _amount) public view returns (bool) 
    {
        if(_sender == owner() && _receiver == address(0)) return true;
        if(_sender == address(0) && _receiver == identityRegistry.treasury()) return true;
       // if (!(_sender == owner() || _receiver == owner() || msg.sender == address(marketplace))) revert UnauthorizedUser(); declarer marketplace
        if(identityRegistry.isFreeze(_sender)) revert UserFreezed(_sender);
        if(identityRegistry.isFreeze(_receiver)) revert UserFreezed(_receiver) ;
        if(!identityRegistry.isWhiteListed(_sender)) revert SenderNotKyc(_sender);
        if(!identityRegistry.isWhiteListed(_receiver)) revert ReceiverNotKyc(_receiver);
        if( _receiver == address(0)) revert UnauthorizedBurn(_sender);
        if(realToken.balanceOf(_receiver) + _amount > getMaxSupplyPerUser()) revert ReceiverUpMaxSupply(_receiver);
        return true;
        // gerer la revente des token d'un investisseurs vers la treasury. marketplace
        // gerer le burn (destruction/revente... d'un bien) !
        // Implementer timelock
    }
}