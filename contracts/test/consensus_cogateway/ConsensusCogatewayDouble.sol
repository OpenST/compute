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

import "../../consensus-gateway/ConsensusCogateway.sol";

/**
 * @title ConsensusCogatewayDouble contract.
 *
 * @notice Test contract used for testing ConsensusCogateway contract.
 */
contract ConsensusCogatewayDouble is ConsensusCogateway {

    /* Special Function */

    constructor()
     public
     ConsensusCogateway()
     { }


    /* External Functions */

    /**
     * It sets current metablock height.
     *
     * @param _metablockHeight Current metablock height.
     */
    function setMetablock(uint256 _metablockHeight) external {
        currentMetablockHeight = _metablockHeight;
    }

    /**
     * @notice It sets storage roots for a block number.
     *
     * @param _blockNumber Block number.
     * @param _storageRoot Storage root at block number.
     */
    function setStorageRoots(uint256 _blockNumber, bytes32 _storageRoot) external {
        storageRoots[_blockNumber] = _storageRoot;
    }

    /**
     * @notice It sets inbound channel identifier.
     *
     * @param _inboundChannelIdentifier Inboundchannel identifier.
     */
    function setInboundChannelIdentifier(bytes32 _inboundChannelIdentifier) external {
        inboundChannelIdentifier =  _inboundChannelIdentifier;
    }
}
