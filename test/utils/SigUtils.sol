// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Base.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

contract Util is CommonBase {
    function test() public { }

    function sign(uint256 privateKey, address contractAddress, address to, uint256 nofyId) external pure returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 digest = keccak256(abi.encodePacked(contractAddress, to, nofyId));
        return vm.sign(privateKey, digest);
    }
}
