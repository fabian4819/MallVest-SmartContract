// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";

import {RevenueOracle} from "../../src/revenue_stream/RevenueOracle.sol";
import {MockUSDC} from "../../src/token_exchange/MockUSDC.sol";

contract RevenueOracleTest is Test {
    RevenueOracle revenueOracle;
    address oracle = address(0x123);
    bytes32 jobId = bytes32("29fa9aa13bf1468788b7cc4a500a45b8"); // example jobId

    function setUp() public {
        MockUSDC usdc = new MockUSDC(1e18, "LaLoUSDC", "LUSDC");
        revenueOracle = new RevenueOracle(oracle, jobId, address(usdc));
        // Fund RevenueOracle with USDC so it can pay fee
        usdc.transfer(address(revenueOracle), 1e18); // amount >= fee in your contract
    }

    function testInitialRevenueIsZero() public view {
        uint256 rev = revenueOracle.revenue();
        assertEq(rev, 0);
    }

    function testRequestRevenueReturnsRequestId() public {
        // This will return a requestId (bytes32)
        bytes32 requestId = revenueOracle.requestRevenue("0xabcde", "2025-06");
        assert(requestId != bytes32(0));
    }
}
