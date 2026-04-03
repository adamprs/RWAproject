// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface IRWAToken {

    function initialize(string memory name, string memory symbol, address treasury, uint256 _totalSupply)external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address _user) external view returns (uint256);
}