// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Proof of Existence
/// @notice Lets anyone timestamp a document on-chain by storing its hash.
///         The file itself never touches the blockchain — only its SHA-256
///         fingerprint does. Anyone can later prove a document existed at a
///         given time by re-hashing it and checking it against the record.
contract ProofOfExistence {
    struct Record {
        address submitter;
        uint256 timestamp;
        string label; // optional human-readable note, e.g. filename
    }

    // hash => record
    mapping(bytes32 => Record) private records;

    event Notarized(
        bytes32 indexed hash,
        address indexed submitter,
        uint256 timestamp,
        string label
    );

    /// @notice Store a hash on-chain if it hasn't been notarized already.
    /// @param hash The keccak256 or sha256 digest of the document (as bytes32).
    /// @param label Optional label (e.g. filename) for display purposes only.
    function notarize(bytes32 hash, string calldata label) external {
        require(records[hash].timestamp == 0, "Already notarized");

        records[hash] = Record({
            submitter: msg.sender,
            timestamp: block.timestamp,
            label: label
        });

        emit Notarized(hash, msg.sender, block.timestamp, label);
    }

    /// @notice Check whether a hash has been notarized, and if so, by whom and when.
    function verify(bytes32 hash)
        external
        view
        returns (bool exists, address submitter, uint256 timestamp, string memory label)
    {
        Record memory r = records[hash];
        if (r.timestamp == 0) {
            return (false, address(0), 0, "");
        }
        return (true, r.submitter, r.timestamp, r.label);
    }
}
