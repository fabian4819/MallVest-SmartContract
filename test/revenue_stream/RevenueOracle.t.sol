// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/revenue_stream/RevenueOracleTestable.sol";

contract RevenueOracleTest is Test {
    RevenueOracleTestable oracle;

    // Dummy router address, can be anything for testing
    address dummyRouter = address(0x1234);
    uint64 dummySubscriptionId = 1;

    // Events for testing
    event RevenueUpdated(address vault, uint256 revenue);

    function setUp() public {
        oracle = new RevenueOracleTestable(dummyRouter, dummySubscriptionId);
    }

    function testFulfillRequestUpdatesRevenue() public {
        // Simulate encoded uint256 revenue returned from oracle
        uint256 fakeRevenue = 123456789;

        // Encode fakeRevenue as bytes (like oracle response)
        bytes memory fakeResponse = abi.encode(fakeRevenue);

        // No error bytes (empty)
        bytes memory emptyError = "";

        // Expect event RevenueUpdated emitted with correct params
        vm.expectEmit(true, true, false, true);
        emit RevenueUpdated(address(this), fakeRevenue);

        // Call the test function that exposes fulfillRequest
        oracle.testFulfillRequest(fakeResponse, emptyError);

        // Check that lastRevenue for this caller is updated
        uint256 storedRevenue = oracle.lastRevenue(address(this));
        assertEq(storedRevenue, fakeRevenue, "Revenue not updated correctly");
    }

    function testFulfillRequestRevertsOnError() public {
        // Simulate error bytes (non-empty)
        bytes memory errorBytes = abi.encodePacked("error occurred");

        // Any response data (can be empty)
        bytes memory dummyResponse = "";

        // Expect revert with message "Chainlink oracle returned error"
        vm.expectRevert(bytes("Chainlink oracle returned error"));

        // This should revert
        oracle.testFulfillRequest(dummyResponse, errorBytes);
    }
}
