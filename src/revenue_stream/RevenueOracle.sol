// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ChainlinkClient} from "@chainlink/operatorforwarder/ChainlinkClient.sol";
import {Chainlink} from "@chainlink/operatorforwarder/Chainlink.sol";

contract RevenueOracle is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    uint256 public revenue;

    constructor(address _oracle, bytes32 _jobId, address _link) {
        _setChainlinkToken(_link);
        oracle = _oracle;
        jobId = _jobId;
        fee = 0.1 * 10 ** 18;
    }

    function requestRevenue(string memory vaultAddress, string memory period) public returns (bytes32) {
        Chainlink.Request memory req = _buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        req._add("vaultAddress", vaultAddress);
        req._add("period", period);

        return _sendChainlinkRequestTo(oracle, req, fee);
    }

    function fulfill(bytes32 _requestId, uint256 _revenue) public recordChainlinkFulfillment(_requestId) {
        revenue = _revenue;
    }
}
