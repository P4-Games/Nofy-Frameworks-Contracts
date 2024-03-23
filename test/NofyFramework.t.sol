// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console2 } from "forge-std/Test.sol";
import { NofyFramework } from "../src/NofyFramework.sol";
import { Util } from "./utils/SigUtils.sol";

contract NofyFrameworkTest is Test {
    NofyFramework public nofy;
    uint256 internal constant validatorPrivateKey = 0x1;
    uint256 internal constant alicePrivateKey = 0x2;
    uint256 internal constant bobPrivateKey = 0x3;

    address internal validator = vm.addr(validatorPrivateKey);
    address internal alice = vm.addr(alicePrivateKey);
    address internal bob = vm.addr(bobPrivateKey);

    Util internal util;

    function setUp() public {
        nofy = new NofyFramework(validator);
        vm.startPrank(alice);
        util = new Util();
    }

    function test_MintMinMax() public {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = util.sign(validatorPrivateKey, address(nofy), alice, 0);
        nofy.mint(0, v, r, s);
        assertEq(nofy.ownerOf(0), alice);

        uint256 max = nofy.total() - 1;
        (v, r, s) = util.sign(validatorPrivateKey, address(nofy), alice, max);
        nofy.mint(max, v, r, s);
        assertEq(nofy.ownerOf(max), alice);
    }

    function test_RevertMintMoreThanTotal() public {
        uint256 nofyId = nofy.total();

        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = util.sign(validatorPrivateKey, address(nofy), alice, nofyId);
        vm.expectRevert(abi.encodeWithSelector(NofyFramework.NofyInvalidMint.selector, nofyId));
        nofy.mint(nofyId, v, r, s);
    }

    function testFuzz_Mint(uint256 nofyId) public {
        nofyId = bound(nofyId, 0, nofy.total() - 1);

        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = util.sign(validatorPrivateKey, address(nofy), alice, nofyId);
        nofy.mint(nofyId, v, r, s);
        assertEq(nofy.ownerOf(nofyId), alice);
    }

    function testFuzz_RevertAlreadyMinted(uint256 nofyId) public {
        nofyId = bound(nofyId, 0, nofy.total() - 1);

        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = util.sign(validatorPrivateKey, address(nofy), alice, nofyId);
        nofy.mint(nofyId, v, r, s);
        assertEq(nofy.ownerOf(nofyId), alice);

        vm.expectRevert(abi.encodeWithSelector(NofyFramework.NofyAlreadyMinted.selector, nofyId));
        nofy.mint(nofyId, v, r, s);
        assertEq(nofy.ownerOf(nofyId), alice);
    }

    function testFuzz_RevertInvalidSignature(uint256 nofyId) public {
        nofyId = bound(nofyId, 0, nofy.total() - 1);

        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = util.sign(alicePrivateKey, address(nofy), alice, nofyId);
        vm.expectRevert(abi.encodeWithSelector(NofyFramework.MintSignatureInvalid.selector, alice, validator));
        nofy.mint(nofyId, v, r, s);
    }
}
