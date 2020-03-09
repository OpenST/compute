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

import "../../utility-token/UtilityTokenInterface.sol";

/**
 * @title UtBase spy contract to test ConsensusCogateway::confirmDeposit.
 */
contract UtBaseConfirmDepositSpy is UtilityTokenInterface {

    /* Storage */

    address[] public beneficiaries;
    uint256[] public amounts;


    /* External Functions. */

    /**
     * @notice It provides address of value token.
     *
     * @return valueTokenAddress_ Value token address.
     */
    function valueToken()
        external
        returns (
            address valueTokenAddress_
        )
    {
        valueTokenAddress_ = address(1);
    }

    /**
     * @notice Used for unit testing of ConsensusCogateway::confirmDeposit.
     *
     * @param _beneficiary Address of beneficiary where tokens are minted.
     * @param _amount Amount in wei.
     */
    function mint(
        address payable _beneficiary,
        uint256 _amount
    )
        external
    {
        beneficiaries.push(_beneficiary);
        amounts.push(_amount);
    }

    /**
     * @notice Implemented to satisfy the interface definition.
     */
    function burn(uint256)
        external
    {
        require(false, "This method should not be called.");
    }

    /**
     * @notice Implemented to satisfy the interface definition.
     */
    function burnFrom(address, uint256)
        external
    {
        require(false, "This method should not be called from unit tests.");
    }

}
