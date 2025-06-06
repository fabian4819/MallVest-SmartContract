// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {
    constructor(uint256 initialTokens, string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, initialTokens * 10 ** 6);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success) {
        _transfer(msg.sender, to, value);

        // Simulate the call to onTokenTransfer (required for Chainlink Oracle)
        (bool ok,) = to.call(abi.encodeWithSelector(
            bytes4(keccak256("onTokenTransfer(address,uint256,bytes)")),
            msg.sender,
            value,
            data
        ));
        require(ok, "onTokenTransfer failed");

        return true;
    }
}
