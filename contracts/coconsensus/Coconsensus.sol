pragma solidity >=0.5.0 <0.6.0;

// Copyright 2020 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import "../anchor/ObserverI.sol";
import "../block/BlockHeader.sol";
import "../coconsensus/GenesisCoconsensus.sol";
import "../protocore/ProtocoreI.sol";
import "../proxies/MasterCopyNonUpgradable.sol";
import "../version/MosaicVersion.sol";

/**
 * @title Coconsensus contract - This mirrors the consensus contract on
 *        the auxiliary chain.
 */
contract Coconsensus is MasterCopyNonUpgradable, GenesisCoconsensus, MosaicVersion {

    /* Enums */

    /** Enum for status of committed checkpoint. */
    enum CheckpointCommitStatus {
        Undefined,
        Committed,
        Finalized
    }


    /* Structs */

    /** Struct to track dynasty and checkpoint commit status of a block. */
    struct Block {
        bytes32 blockHash;
        CheckpointCommitStatus commitStatus;
        uint256 statusDynasty;
    }


    /* Constants */

    /**
     * Sentinel pointer for marking the ending of circular,
     * linked-list of genesis metachain ids.
     */
    bytes32 public constant SENTINEL_METACHAIN_ID = bytes32(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);


    /* Storage */

    /** Metachain id of the origin chain. */
    bytes32 public originMetachainId;

    /** Metachain id of the auxiliary chain. */
    bytes32 public auxiliaryMetachainId;

    /** Mapping to track the blocks for each metachain. */
    mapping (bytes32 /* metachainId */ =>
        mapping(uint256 /* blocknumber */ => Block)
    ) public blockchains;

    /**
     * Mapping of metachain id to latest block number(tip) stored
     * in blockchains.
     */
    mapping (bytes32 /* metachainId */ => uint256 /* blocknumber */) public blockTips;

    /** Mapping of metachain id to the protocore contract address. */
    mapping (bytes32 /* metachainId */ => ProtocoreI) public protocores;

    /** Mapping of metachain id to the observers contract address. */
    mapping (bytes32 /* metachainId */ => ObserverI) public observers;

    /** Mapping of metachain id to the domain separators. */
    mapping (bytes32 /* metachainId */ => bytes32 /* domain separator */) public domainSeparators;


    /* Special Functions */

    /**
     * @notice Setup function does the initialization of all the mosaic
     *         contracts on the auxiliary chain.
     *
     * @dev This function can be called only once.
     */
    function setup() public {

        require(
            originMetachainId == bytes32(0),
            "Coconsensus contract is already initialized."
        );

        originMetachainId = genesisOriginMetachainId;
        auxiliaryMetachainId = genesisAuxiliaryMetachainId;

        /*
         * Setup self protocore contract first. All other protocores will
         * require the dynasty from the self protocore to finalise the genesis
         * checkpoint.
         */
        setupProtocores(auxiliaryMetachainId);

        bytes32 currentMetachainId = genesisMetachainIds[SENTINEL_METACHAIN_ID];

        // Loop through the genesis metachainId link list.
        while (currentMetachainId != SENTINEL_METACHAIN_ID) {
            /*
             * The setup of self protocore is already done as a first step so
             * skip the protocore setup if the current metachain id is equal to
             * the auxiliary metachain id.
             */
            if (currentMetachainId != auxiliaryMetachainId) {
                // Setup protocore contract for the given metachain id.
                setupProtocores(currentMetachainId);
            }

            // Setup observer contract for the given metachain id.
            setupObservers(currentMetachainId);

            // Traverse to next metachain id from the link list mapping.
            currentMetachainId = genesisMetachainIds[currentMetachainId];
        }
    }


    /* External Functions */

    /**
     * @notice Anchor the state root in to the observer contracts.
     *
     * @param _metachainId Metachain id.
     * @param _rlpBlockHeader RLP encoded block header.
     *
     * /pre `_metachainId` is not 0.
     * /pre `_rlpBlockHeader` is not 0.
     * /pre `blockHash` should exist in blockchains.
     * /pre The dynasty of the reported block should be less than current dynasty.
     * /pre The reported block should be finalized.
     *
     * /post Anchor the state root in the observer contract.
     */
    function observeBlock(
        bytes32 _metachainId,
        bytes calldata _rlpBlockHeader
    )
        external
    {
        require(
            _metachainId != bytes32(0),
            "Metachain id must not be null."
        );

        require(
            _rlpBlockHeader.length != 0,
            "RLP block header must not be null."
        );

        // Decode the rlp encoded block header.
        BlockHeader.Header memory blockHeader = BlockHeader.decodeHeader(_rlpBlockHeader);

        Block memory blockStatus = blockchains[_metachainId][blockHeader.height];

        require(
            blockStatus.blockHash == blockHeader.blockHash,
            "Provided block header is not valid."
        );

        require(
            blockStatus.commitStatus > CheckpointCommitStatus.Committed,
            "Block must be at least finalized."
        );

        // Get the current dynasty from the self protocore.
        ProtocoreI protocore = protocores[auxiliaryMetachainId];
        uint256 currentDynasty = protocore.dynasty();

        require(
            currentDynasty > blockStatus.statusDynasty,
            "Block dynasty must be less than current dynasty."
        );

        // Get the observer contract.
        ObserverI observer = observers[_metachainId];

        // Anchor the state root.
        observer.anchorStateRoot(blockHeader.height, blockHeader.stateRoot);
    }

    /* Private Functions */

    /**
     * @notice Do the initial setup of protocore contract and initialize the
     *         storage of coconsensus contract.
     *
     * @param _metachainId Metachain id.
     *
     * /pre `protocoreAddress` is not 0
     *
     * /post Setup protocore contract.
     * /post Set `protocores` mapping with the protocore address.
     * /post Set `domainSeparators` mapping with domain separator.
     * /post Set `blockchains` mapping with Block object.
     * /post Set `blockTips` mapping with the block number.
     */
    function setupProtocores(bytes32 _metachainId) private {

        // Get the protocore contract address from the genesis storage.
        address protocoreAddress = genesisProtocores[_metachainId];

        require(
            protocoreAddress != address(0),
            "Protocore address must not be null."
        );

        // Setup protocore.
        ProtocoreI protocore = ProtocoreI(protocoreAddress);
        protocore.setup();

        // Store the protocore address in protocores mapping.
        protocores[_metachainId] = protocore;

        // Get the domain separator and store it in domainSeparators mapping.
        domainSeparators[_metachainId] = protocore.domainSeparator();

        // Get block number and block hash of the genesis link.
        ( uint256 blockNumber, bytes32 blockHash ) = protocore.latestFinalizedCheckpoint();

        // Get the dynasty from self protocore contract.
        ProtocoreI selfProtocore = ProtocoreI(genesisProtocores[auxiliaryMetachainId]);
        uint256 dynasty = selfProtocore.dynasty();

        // Store the block informations in blockchains mapping.
        blockchains[_metachainId][blockNumber] = Block(
            blockHash,
            CheckpointCommitStatus.Finalized,
            dynasty
        );

        // Store the blocknumber as tip.
        blockTips[_metachainId] = blockNumber;
    }

    /**
     * @notice Do the initial setup of observer contract and initialize the
     *         storage of coconsensus contract.
     *
     * @param _metachainId Metachain id
     *
     * /pre `observerAddress` is not 0
     *
     * /post Setup observer contract.
     * /post Set `observers` mapping with the observer address.
     */
    function setupObservers(bytes32 _metachainId) private {
        // Get the observer contract address from the genesis storage.
        address observerAddress = genesisObservers[_metachainId];
        if(observerAddress != address(0)) {
            // Call the setup function.
            ObserverI observer = ObserverI(observerAddress);
            observer.setup();

            // Update the observers mapping.
            observers[_metachainId] = observer;
        }
    }
}
