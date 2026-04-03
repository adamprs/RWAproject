// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface ICompliance {

    function canTransfer(address _sender, address _receiver, uint256 _amount) external view returns (bool);
}