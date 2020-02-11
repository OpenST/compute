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

/**
 * @title Genesis coconsensus contract is a storage contract that holds
 *        the initial values required by the contract that were written in the
 *        genesis block. This contract stores the origin metachain id,
 *        self metachain id, observer contract addresses, protocore contract
 *        addresses. The metachain ids are stored as a linked list so that it
 *        can be iterable.
 */
contract GenesisCoconsensus {

    /* Storage */

    /** Metachain id of the origin chain. */
    bytes32 public genesisOriginMetachainId;

    /** Metachain id of the auxiliary chain. */
    bytes32 public genesisSelfMetachainId;

    /** Link list of metachain ids (for all protocores). */
    mapping(bytes32 => bytes32) public genesisMetachainIds;

    /**
     * Mapping of metachain id to its observers (anchor) contract
     * address on auxiliary chain.
     */
    mapping(bytes32 => address) public genesisObservers;

    /**
     * Mapping of metachain id to its protocore contract
     * address on auxiliary chain.
     */
    mapping(bytes32 => address) public genesisProtocores;
}
