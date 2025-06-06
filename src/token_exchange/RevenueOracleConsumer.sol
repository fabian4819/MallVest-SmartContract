// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/operatorforwarder/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract RevenueOracleConsumer is ChainlinkClient, Ownable {
    using Chainlink for Chainlink.Request;

    uint256 public lastReportedRevenue;
    address public oracle;
    bytes32 public jobId;
    uint256 public fee;

    event RevenueReceived(uint256 revenue);

    constructor(address _link, address _oracle, bytes32 _jobId, uint256 _fee) {
        _setChainlinkToken(_link);
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
    }

    function requestRevenue() public onlyOwner {
        Chainlink.Request memory req = _buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        _sendChainlinkRequestTo(oracle, req, fee);
    }

    function fulfill(bytes32 _requestId, uint256 _revenue) public recordChainlinkFulfillment(_requestId) {
        lastReportedRevenue = _revenue;
        emit RevenueReceived(_revenue);
    }
}
