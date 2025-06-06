// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract RevenueOracle is ChainlinkClient, ConfirmedOwner {
    error InsufficientBalance();

    using Chainlink for Chainlink.Request;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    uint256 public revenue;

    constructor() ConfirmedOwner(msg.sender) {
        // Set the LINK token address (Sepolia)
        _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);

        // Oracle and jobId must match what's deployed on Chainlink node
        oracle = 0x0FaCf846af22BCE1C7f88D1d55A038F27747eD2B;
        jobId = 0x6138333536663438353639633433346561613461633566636234646235636330;

        // 1 LINK (in wei)
        fee = 1 * 10 ** 18;
    }

    function requestRevenue(string memory vaultAddress, string memory period) public returns (bytes32 requestId) {
        if (LinkTokenInterface(_chainlinkTokenAddress()).balanceOf(address(this)) < fee) {
            revert InsufficientBalance();
        }

        Chainlink.Request memory req = _buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        string memory url = string(abi.encodePacked(
            "https://mall-vest-backend.vercel.app/reports/",
            vaultAddress,
            "/",
            period
        ));

        req._add("url", url);
        req._add("path", "data.revenue");       // Use dot notation for nested JSON
        req._addInt("times", 10 ** 18);         // Use `times` not `multiplier`

        // Make the request
        requestId = _sendChainlinkRequestTo(oracle, req, fee);
    }

    function fulfill(bytes32 _requestId, uint256 _revenue) public recordChainlinkFulfillment(_requestId) {
        revenue = _revenue;
    }

    function getLinkBalance() external view returns (uint256) {
    return LinkTokenInterface(0x779877A7B0D9E8603169DdbD7836e478b4624789).balanceOf(address(this));
}

}
