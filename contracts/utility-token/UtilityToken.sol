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

import "./ERC20Token.sol";

/**
 *  @title UtilityToken is an ERC20Token.
 *
 *  @notice This contract extends the functionalities of the ERC20Token.
 *
 */
contract UtilityToken is ERC20Token {

    /* Events */

    /** Emitted whenever a ConsensusCogateway address is set */
    event ConsensusCogatewaySet(address _consensusCogateway);


    /* Storage */

    /** Address of ConsensusCogateway contract. */
    address public consensusCogateway;


    /* Modifiers */

    /** Checks that only ConsensusCogateway can call a particular function. */
    modifier onlyConsensusCogateway() {
        require(
            msg.sender == address(consensusCogateway),
            "Only ConsensusCogateway can call the function."
        );

        _;
    }


    /* External Functions */

    /**
     * @notice External function to mint tokens.
     *
     * @dev Mints an amount of the token and assigns it to an account.
     *      This encapsulates the modification of balances such that the
     *      proper events are emitted.
     * @param _account The account that will receive the created tokens.
     * @param _value The amount that will be created.
     *
     * @return success_ `true` for a successful mint, `false` otherwise.
     */
    function mint(address _account, uint256 _value)
        external
        onlyConsensusCogateway()
        returns (bool success_)
    {
        _mint(_account, _value);

        emit Transfer(address(0), _account, _value);

        success_ = true;
    }

    /**
     * @notice External function to burn tokens.
     *
     * @dev Burns an amount of the token of a given
     *      account. Calls the internal burn function.
     * @param _account The account whose tokens will be burnt.
     * @param _value The amount that will be burnt.
     *
     * @return success_ `true` for a successful burn, `false` otherwise.
     */
    function burn(address _account, uint256 _value)
        external
        returns (bool success_)
    {
        _burn(_account, _value);

        success_ = true;
    }

    /**
     * @notice External function to burn tokens of spender.
     *
     * @dev Burns an amount of the token of a given
     *      account, deducting from the sender's allowance for said
     *      account. Uses the internal _burnFrom function.
     * @param _account The account whose tokens will be burnt.
     * @param _value The amount that will be burnt.
     *
     * @return success_ `true` for a successful burnFrom, `false` otherwise.
     */
    function burnFrom(address _account, uint256 _value)
        external
        returns (bool success_)
    {
        _burnFrom(_account, _value);

        success_ = true;
    }


    /** Internal Functions */

    /**
     * @notice Sets up the symbol, name, decimals, totalSupply
     *         and the consensusCogateway address
     *
     * @param _symbol Symbol of token.
     * @param _name Name of token.
     * @param _decimals Decimal of token.
     * @param _totalTokenSupply Total token supply.
     * @param _consensusCogateway ConsensusCogateway contract address.
     *
     * @return success_ `true` for a successful setup, `false` otherwise.
     */
    function setup(
        string memory _symbol,
        string memory _name,
        uint8 _decimals,
        uint256 _totalTokenSupply,
        address _consensusCogateway
    )
        internal
        returns (bool success_)
    {
        require(
            consensusCogateway == address(0),
            "ConsensusCogateway address is already set."
        );

        require(
            _consensusCogateway != address(0),
            "ConsensusCogateway address should not be zero."
        );

        tokenSymbol = _symbol;
        tokenName = _name;
        tokenDecimals = _decimals;
        totalTokenSupply = _totalTokenSupply;
        consensusCogateway = _consensusCogateway;

        success_ = true;
    }
}
