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

import "../../reputation/Coreputation.sol";

/**
 * @title CoreputationTest contract.
 */
contract CoreputationTest is Coreputation {

    CoconsensusI public coconsensus;


    /* Special Functions */

    constructor(
        CoconsensusI _coconsensus
    )
        public
    {
        coconsensus = _coconsensus;
    }


    /* External Functions */

    function setValidatorSlashed(
        address _validator
    )
        external
    {
        ValidatorInfo storage vInfo = validators[_validator];
        vInfo.status = ValidatorStatus.Slashed;
        vInfo.reputation = uint256(0);
    }


     /* Public Functions */

    function getCoconsensus() public view returns (CoconsensusI) {
        return coconsensus;
    }
}
