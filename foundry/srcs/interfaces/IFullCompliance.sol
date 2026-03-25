// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface IFullCompliance {

    function maxOwnershipBPS() external view returns (uint256);

    function initialize(address _identityRegistry, address _realToken) external ;

    function setIdentityRegistry(address _identityRegistry) external ;

    function setRealToken(address _realToken) external;

    function setNewMaxOwnershipBPS(uint256 newMaxOwnershipBPS) external;
    
    function canTransfer(address _sender, address _receiver, uint256 _amount) external view returns (bool);

}