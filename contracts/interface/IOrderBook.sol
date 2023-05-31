// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../libraries/Orders.sol";

interface IOrderBook {

    event OrderCreated(bytes32 indexed hash);
    function createOrder(Orders.Order memory order) external;

}
