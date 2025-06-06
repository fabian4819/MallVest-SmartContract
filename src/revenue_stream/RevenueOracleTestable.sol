// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RevenueOracle} from "./RevenueOracle.sol";

contract RevenueOracleTestable is RevenueOracle {
    constructor(address router, uint64 subscriptionId) RevenueOracle(router, subscriptionId) {}

    // Expose internal fulfillRequest for testing
    function testFulfillRequest(bytes memory response, bytes memory err) external {
        fulfillRequest(bytes32(0), response, err);
    }
}
