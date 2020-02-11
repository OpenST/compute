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

import "../../validator-set/ValidatorSet.sol";

/**
 * @title ValidatorSetDouble contract.
 *
 * @notice It is used for testing ValidatorSet contract.
 */
contract ValidatorSetDouble is ValidatorSet {

    /* External Functions */

    function setupValidatorSetDouble(uint256 _activeHeight)
        external
    {
        ValidatorSet.setupValidatorSet(_activeHeight);
    }

    /**
     * \ref ValidatorSet.insertValidatorInternal(address,uint256).
     */
    function insertValidator(address _validator, uint256 _beginHeight) external {
        ValidatorSet.insertValidatorInternal(_validator, _beginHeight);
    }

    /**
     * \ref ValidatorSet.removeValidatorInternal(address,uint256).
     */
    function removeValidator(address _validator, uint256 _endHeight) external {
        ValidatorSet.removeValidatorInternal(_validator, _endHeight);
    }

    /**
     * \ref ValidatorSet.incrementActiveHeightInternal(uint256).
     */
    function incrementActiveHeight(uint256 _nextHeight) external {
        ValidatorSet.incrementActiveHeightInternal(_nextHeight);
    }
}
