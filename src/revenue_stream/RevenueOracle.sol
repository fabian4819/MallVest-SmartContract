// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import {Chainlink} from "@chainlink/operatorforwarder/Chainlink.sol";
import {ChainlinkClient} from "@chainlink/operatorforwarder/ChainlinkClient.sol";
import {ConfirmedOwner} from "@chainlink/shared/access/ConfirmedOwner.sol";

contract RevenueOracle is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    // Store responses by vaultAddress => period => revenue
    mapping(address => mapping(string => uint256)) public responses;

    // Temporary storage to track request metadata
    struct RequestMeta {
        address vaultAddress;
        string period;
    }

    mapping(bytes32 => RequestMeta) private requestMeta;

    address public oracleAddress;
    bytes32 public jobId;
    uint256 public fee;

    constructor() ConfirmedOwner(msg.sender) {
        // LINK Token
        _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        // LinkWell Oracle
        oracleAddress = 0x0FaCf846af22BCE1C7f88D1d55A038F27747eD2B;
        _setChainlinkOracle(oracleAddress);
        jobId = "a8356f48569c434eaa4ac5fcb4db5cc0";
        fee = 0; // 0 LINK job
    }

    function requestRevenue(address vaultAddress, string memory period) public {
        Chainlink.Request memory req = _buildOperatorRequest(jobId, this.fulfill.selector);

        req._add("method", "POST");
        req._add("url", "https://mall-vest-external-adapter.vercel.app/");
        req._add("headers", '["Content-Type", "application/json"]');

        string memory json = string(abi.encodePacked(
            '{"id":"test-job-123","data":{"vaultAddress":"',
            toAsciiString(vaultAddress),
            '","period":"',
            period,
            '"}}'
        ));

        req._add("body", json);
        req._add("path", "result");
        req._addInt("multiplier", 1);
        req._add("contact", "yitzhaketmanalu@gmail.com");

        bytes32 requestId = _sendOperatorRequest(req, fee);
        requestMeta[requestId] = RequestMeta(vaultAddress, period);
    }

    function fulfill(bytes32 _requestId, uint256 _data) public recordChainlinkFulfillment(_requestId) {
        RequestMeta memory meta = requestMeta[_requestId];
        responses[meta.vaultAddress][meta.period] = _data;

        // Clean up to save gas (optional)
        delete requestMeta[_requestId];
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(42);
        s[0] = '0';
        s[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 + 2*i] = char(hi);
            s[3 + 2*i] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    // // Add this in RevenueFetcher for test purposes only
    // function __testSetRequestMeta(bytes32 requestId, address vaultAddress, string memory period) public {
    //     requestMeta[requestId] = RequestMeta(vaultAddress, period);
    // }
}
