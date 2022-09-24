// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract GasPriceNoEvent {

    event Receive(address sender, uint value);

    receive() external payable{}
}