// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "../dataTypes/dataTypes.sol";

interface IIdentityRegistry {

    function isWhiteListed(address _user) external view returns (bool);
    function isFreeze(address _user) external view returns (bool);
    function treasury() external view returns (address);
    function registerUsersTokens(address _user, address _token, uint256 value) external;
    function tokenHolders() external view returns (address [] memory);
  //  function getUsersBuy(address user) external view returns(BuyTime [] memory);
    function getUsersBuy(address _user, address _token) external returns (BuyTime [] memory);
    function setUsersBuyTokenNum(address _user, address _token, uint256 index, uint256 value) external;
    function batchIndex(address _user, address _token) external returns (uint256);
    function setUsersBuyIndex(address _user, address _token, uint256 newIndex) external;
}