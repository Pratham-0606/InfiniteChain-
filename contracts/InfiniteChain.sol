// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract InfiniteChain {
    struct Record {
        address submitter;
        uint256 timestamp;
        string metadata; // e.g., document hash, IPFS link, description
        bool active;
    }

    uint256 private nextRecordId = 1;
    mapping(uint256 => Record) private records;
    mapping(bytes32 => uint256) private hashToRecordId;

    event RecordSubmitted(uint256 indexed recordId, address indexed submitter, string metadata, bytes32 docHash);
    event RecordUpdated(uint256 indexed recordId, string newMetadata);
    event RecordDeactivated(uint256 indexed recordId);

    /// @notice Submit a new record with hash & metadata
    function submitRecord(bytes32 docHash, string memory metadata) external returns (uint256) {
        require(docHash != bytes32(0), "Invalid hash");
        require(hashToRecordId[docHash] == 0, "Record already exists");

        uint256 recordId = nextRecordId++;
        records[recordId] = Record({
            submitter: msg.sender,
            timestamp: block.timestamp,
            metadata: metadata,
            active: true
        });

        hashToRecordId[docHash] = recordId;
        emit RecordSubmitted(recordId, msg.sender, metadata, docHash);
        return recordId;
    }

    /// @notice Update metadata for a record (only submitter)
    function updateRecord(uint256 recordId, string memory newMetadata) external {
        Record storage r = records[recordId];
        require(r.submitter == msg.sender, "Not submitter");
        require(r.active, "Record inactive");

        r.metadata = newMetadata;
        emit RecordUpdated(recordId, newMetadata);
    }

    /// @notice Deactivate a record (only submitter)
    function deactivateRecord(uint256 recordId) external {
        Record storage r = records[recordId];
        require(r.submitter == msg.sender, "Not submitter");
        require(r.active, "Already inactive");

        r.active = false;
        emit RecordDeactivated(recordId);
    }

    /// @notice Retrieve record details by record ID
    function getRecord(uint256 recordId) external view returns (address submitter, uint256 timestamp, string memory metadata, bool active) {
        Record memory r = records[recordId];
        require(r.timestamp != 0, "Record not found");
        return (r.submitter, r.timestamp, r.metadata, r.active);
    }

    /// @notice Find record by hash
    function findRecordByHash(bytes32 docHash) external view returns (uint256) {
        return hashToRecordId[docHash];
    }

    /// @notice Total records submitted
    function totalRecords() external view returns (uint256) {
        return nextRecordId - 1;
    }
}
