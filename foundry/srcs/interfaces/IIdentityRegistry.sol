// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface IIdentityRegistry {

    function isWhiteListed(address _user) external view returns (bool);
    function treasury() external view returns (address);
}