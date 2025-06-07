// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {RevenueOracle} from "../src/revenue_stream/RevenueOracle.sol";

contract DeployRevenueOracle is Script {
    function run() external {
        vm.startBroadcast();
        new RevenueOracle();
        vm.stopBroadcast();
    }
}
