// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "../lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

contract IdentityRegistry is Initializable, OwnableUpgradeable, UUPSUpgradeable
{
    struct Identity {
        string documentHash;
        uint256 registeredAt;
        uint256 firstRegistration;
        bool isActive;
    }

    mapping (address => Identity) public addressToIdentity;

    mapping (address => bool) public isWhiteListed;
    mapping (address => bool) public isFreeze;

    mapping (address => address []) public userTokens;
    mapping (address => mapping(address => bool)) hasToken;

    address [] public tokenHolders;
    mapping (address => bool) public isHolder;

    address public treasury;

    event UserWhiteListed(address indexed _user);
    event UserRegistered(address indexed _user);
    event UserChangedIdentity(address indexed _user);
    event UserRevoked(address indexed _user);
    event UserFreezed(address indexed _user);
    event UserUnFreezed(address indexed _user);

    error ZeroAddress();
    error BadDocumentHash(); // ipfs
    error AlreadyRegistered();
    error UserNeverEnregistered(address _user);


    constructor() {
        _disableInitializers();
    }

    function initialize(address newTreasury) public initializer {
        __Ownable_init(msg.sender);
        setTreasury(newTreasury);

    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {

    }

    function setTreasury(address newTreasury) public onlyOwner {
        if (newTreasury == address(0)) revert ZeroAddress();
            treasury = newTreasury;
            addToWhitelist(treasury);
    }
    // registerIdentity est réaliser par l'admnistration du protocole ( kyc )
    function registerIdentity(address _user, string memory _documentHash, bool _isActive) public onlyOwner
    {
        if(_user == address(0)) revert ZeroAddress();
        if(bytes(_documentHash).length == 0) revert BadDocumentHash();  // a durcir pour accepter ipfs.
        if(bytes(addressToIdentity[_user].documentHash).length != 0) revert AlreadyRegistered();
        addressToIdentity[_user] = Identity(_documentHash, block.timestamp, block.timestamp, _isActive);
        emit UserRegistered(_user);
        if (_isActive)
            addToWhitelist(_user);
    }

    function changeIdentity(address _user, string memory _documentHash, bool _isActive) public onlyOwner
    {
        if(_user == address(0)) revert ZeroAddress();
        if(bytes(_documentHash).length == 0) revert BadDocumentHash();  // a durcir pour accepter ipfs.
        if (addressToIdentity[_user].firstRegistration == 0) revert UserNeverEnregistered(_user);
        Identity memory currentUserIdentity = addressToIdentity[_user];
        bool wasActive = currentUserIdentity.isActive;

        bool hashChanged = keccak256(bytes(currentUserIdentity.documentHash)) != keccak256(bytes(_documentHash));
        bool statusChanged = currentUserIdentity.isActive != _isActive;
        if (hashChanged || statusChanged)
        {
            addressToIdentity[_user] = Identity(_documentHash, block.timestamp, currentUserIdentity.firstRegistration, _isActive);
            emit UserChangedIdentity(_user);
            if (wasActive == false && _isActive == true)
                addToWhitelist(_user);
        }
        if (!_isActive && wasActive)
            revoke(_user);
    }

    function revoke(address _user) internal 
    {
        isWhiteListed[_user] = false;
        emit UserRevoked(_user);
    }

    function freeze(address _user) external onlyOwner
    {
        isFreeze[_user] = true;
        emit UserFreezed(_user);
    }

    function UnFreeze(address _user) external onlyOwner
    {
        if (isFreeze[_user] == true) {
            isFreeze[_user] = false;
            emit UserUnFreezed(_user);
        }
    }

    function addToWhitelist(address _user) internal 
    {
        isWhiteListed[_user] = true;
        emit UserWhiteListed(_user);
    }

    function registerUsersTokens(address _user, address _token) internal 
    {
        if(!hasToken[_user][_token])
        {
            hasToken[_user][_token] == true;
            userTokens[_user].push(_token);
        }

        if(!isHolder[_user])
        {
            tokenHolders.push(_user);
            isHolder[_user] == true;
        }
    }

    // stocker sur ipfs
}
