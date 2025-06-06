// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {FunctionsClient} from "@chainlink/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract RevenueOracle is FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    mapping(address => uint256) public lastRevenue;

    bytes32 public lastRequestId;
    uint64 public subscriptionId;

    event RevenueRequested(bytes32 requestId);
    event RevenueUpdated(address vault, uint256 revenue);

    constructor(address router, uint64 _subscriptionId) FunctionsClient(router) {
        subscriptionId = _subscriptionId;
    }

    function updateRevenue(string memory vaultAddress, string memory period) external {
        FunctionsRequest.Request memory req;

        string memory url = string(
            abi.encodePacked(
                "https://mall-vest-backend.vercel.app/reports/",
                vaultAddress,
                "/",
                period
            )
        );

        string memory source = string(
            abi.encodePacked(
                "const response = await Functions.makeHttpRequest({",
                " url: '", url, "',",
                " method: 'GET'",
                "});",
                "if (response.error) throw Error(JSON.stringify(response));",
                "return Functions.encodeUint256(response.data.totalRevenue);"
            )
        );

        req.initializeRequest(
            FunctionsRequest.Location.Remote,
            FunctionsRequest.CodeLanguage.JavaScript,
            source
        );

        lastRequestId = _sendRequest(req.encodeCBOR(), subscriptionId, 300000, bytes32(0));
        emit RevenueRequested(lastRequestId);
    }

    function fulfillRequest(
        bytes32,
        bytes memory response,
        bytes memory err
    ) internal override {
        require(err.length == 0, "Chainlink oracle returned error");
        uint256 revenue = abi.decode(response, (uint256));
        lastRevenue[msg.sender] = revenue;
        emit RevenueUpdated(msg.sender, revenue);
    }
}
