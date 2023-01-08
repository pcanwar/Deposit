// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

// import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
// import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
contract Sig {
    using ECDSA for bytes32;

    uint256 internal immutable CHAINID;

    bytes32 internal DOMAIN_SEPARATOR;
    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    constructor() {
        CHAINID = block.chainid;
    }

    function run(
        bytes32 _hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual returns (address signer) {
        signer = ECDSA.recover(_hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function _checkSiger(bytes calldata _sig, bytes32 _txHash)
        public
        pure
        returns (address signer_)
    {
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash();
        signer_ = ethSignedHash.recover(_sig);
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "Invalid Signature Length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function _getDataHash(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(owner, spender, value, nonce, deadline));
    }

    function getDataHash(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    uint16(0x1901),
                    _getDataHash(owner, spender, value, nonce, deadline)
                )
            );
    }

    function chainID() private view returns (uint256) {
        return CHAINID;
    }
}
