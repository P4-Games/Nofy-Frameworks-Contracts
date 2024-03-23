// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract NofyFramework is ERC721 {
    error NofyInvalidMint(uint256 nofyId);
    error NofyAlreadyMinted(uint256 nofyId);
    error MintSignatureInvalid(address signer, address validator);

    uint256 public constant total = 120;
    address public validator;

    constructor(address validator_) ERC721("Nofy-Framework", "NoFa") {
        validator = validator_;
    }

    function mint(uint256 nofyId, uint8 v, bytes32 r, bytes32 s) public {
        if (nofyId >= total) {
            revert NofyInvalidMint(nofyId);
        }

        if (_ownerOf(nofyId) != address(0)) {
            revert NofyAlreadyMinted(nofyId);
        }

        bytes32 hash = keccak256(abi.encodePacked(address(this), msg.sender, nofyId));
        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != validator) {
            revert MintSignatureInvalid(signer, validator);
        }

        _safeMint(msg.sender, nofyId);
    }
}
