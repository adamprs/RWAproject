// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface IIdentityRegistry {

    function isWhiteListed(address _user) external view returns (bool);
    function isFreeze(address _user) external view returns (bool);
    function treasury() external view returns (address);
    function registerUsersTokens(address _user, address _token) external;
    function tokenHolders() external view returns (address [] memory);
}