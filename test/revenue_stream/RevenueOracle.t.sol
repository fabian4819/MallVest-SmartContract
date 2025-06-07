// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.7;

// import "forge-std/Test.sol";
// import {RevenueOracle} from "../../src/revenue_stream/RevenueOracle.sol";

// contract RevenueOracleTest is Test {
//     RevenueOracle public fetcher;

//     address vault = address(0xABCD);
//     string period = "2025-06";
//     uint256 fakeRevenue = 420_000;

//     function setUp() public {
//         fetcher = new RevenueOracle();
//     }

//     function testRequestRevenueAndFulfill() public {
//     bytes32 fakeRequestId = keccak256(abi.encodePacked("test-request"));

//     // Inject test metadata
//     fetcher.__testSetRequestMeta(fakeRequestId, vault, period);

//     // Use actual oracle address from the contract
//     vm.prank(fetcher.oracleAddress());

//     fetcher.fulfill(fakeRequestId, fakeRevenue);

//     uint256 stored = fetcher.responses(vault, period);
//     assertEq(stored, fakeRevenue);
// }


// }
