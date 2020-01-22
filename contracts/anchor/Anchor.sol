pragma solidity >=0.5.0 <0.6.0;

// Copyright 2019 OpenST Ltd.
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

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./AnchorI.sol";

import "../consensus/ConsensusModule.sol";
import "../proxies/MasterCopyNonUpgradable.sol";
import "../anchor/StateRootProvider.sol";

/**
 * @title Anchor contract to store the state roots.
 *
 * @notice Anchor stores auxiliary chain's state roots. This contract is a consensus module
 *         and the anchoring of the state root can only be done be consensus contract.
 */
contract Anchor is MasterCopyNonUpgradable, ConsensusModule, StateRootProvider {

    /* External functions */

    /**
     * @notice Setup function for anchor.
     *
     * @param _maxStateRoots The max number of state roots to store in the
     *                       circular buffer.
     * @param _consensus A consensus contract  address.
     */
    function setup(
        uint256 _maxStateRoots,
        ConsensusI _consensus
    )
        external
    {
        StateRootProvider.setup(_maxStateRoots);
        ConsensusModule.setupConsensus(_consensus);
    }

    /**
     * @notice Anchor the state root for an (increasing) block number.
     *
     * @dev  Function requires:
     *          - Only consensus contract address can call this function.
     *
     * @param _blockNumber Block number for which state root needs to
     *                      update.
     * @param _stateRoot State root of input block number.
     */
    function anchorStateRoot(
        uint256 _blockNumber,
        bytes32 _stateRoot
    )
        external
        onlyConsensus
    {
        StateRootProvider.anchorStateRootInternal(_blockNumber, _stateRoot);
    }
}
