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

'use strict';

const BN = require('bn.js');

const ERC20Cogateway = artifacts.require('ERC20CogatewayDouble');
const UtilityToken = artifacts.require('UtilityTokenMock');

const { AccountProvider } = require('../../test_lib/utils.js');
const MessageBusUtils = require('../../message_bus/messagebus_utils');
const Utils = require('../../test_lib/utils.js');

contract('ERC20Cogateway::withdraw', (accounts) => {
  const accountProvider = new AccountProvider(accounts);
  let erc20Cogateway;
  let utilityToken;
  let setupGenesisParams = {};
  let withdrawParam = {};
  let withdrawIntent;
  let sender;
  let outboundChannelIdentifier;
  let valueTokenForUtilityToken;

  beforeEach(async () => {
    erc20Cogateway = await ERC20Cogateway.new();
    const owner = accountProvider.get();
    sender = accountProvider.get();
    valueTokenForUtilityToken = accountProvider.get();
    utilityToken = await UtilityToken.new(valueTokenForUtilityToken, owner, '1000000000000');

    setupGenesisParams = {
      genesisMetachainId: Utils.generateRandomMetachainId(),
      genesisERC20Gateway: accountProvider.get(),
      genesisStateRootProvider: accountProvider.get(),
      genesisMaxStorageRootItems: new BN(100),
      genesisOutboxStorageIndex: new BN(4),
      genesisUtilityTokenMasterCopy: utilityToken.address,
    };

    withdrawParam = {
      utilityToken: utilityToken.address,
      amount: new BN(100),
      beneficiary: accountProvider.get(),
      feeGasPrice: new BN(1),
      feeGasLimit: new BN(1),
    };

    await utilityToken.transfer(
      sender,
      withdrawParam.amount,
      { from: owner },
    );

    await erc20Cogateway.setupGenesis(
      setupGenesisParams.genesisMetachainId,
      setupGenesisParams.genesisERC20Gateway,
      setupGenesisParams.genesisStateRootProvider,
      setupGenesisParams.genesisMaxStorageRootItems,
      setupGenesisParams.genesisOutboxStorageIndex,
      setupGenesisParams.genesisUtilityTokenMasterCopy,
    );

    await erc20Cogateway.setup();

    outboundChannelIdentifier = await erc20Cogateway.outboundChannelIdentifier.call();

    withdrawIntent = await MessageBusUtils.hashWithdrawIntent(
      valueTokenForUtilityToken,
      withdrawParam.utilityToken,
      withdrawParam.amount,
      withdrawParam.beneficiary,
    );
  });

  it('should successfully withdraw', async () => {
    const beforeSenderUtilityTokenBalance = await utilityToken.balanceOf(sender);

    await utilityToken.approve(erc20Cogateway.address, withdrawParam.amount, {
      from: sender,
    });

    const calculatedMessageHash = await MessageBusUtils.hashMessage(
      withdrawIntent,
      new BN(0),
      withdrawParam.feeGasPrice,
      withdrawParam.feeGasLimit,
      sender,
      outboundChannelIdentifier,
    );

    const messageHash = await erc20Cogateway.withdraw.call(
      withdrawParam.amount,
      withdrawParam.beneficiary,
      withdrawParam.feeGasPrice,
      withdrawParam.feeGasLimit,
      withdrawParam.utilityToken,
      { from: sender },
    );

    await erc20Cogateway.withdraw(
      withdrawParam.amount,
      withdrawParam.beneficiary,
      withdrawParam.feeGasPrice,
      withdrawParam.feeGasLimit,
      withdrawParam.utilityToken,
      { from: sender },
    );

    const afterSenderUtilityTokenBalance = await utilityToken.balanceOf(sender);
 
    assert.strictEqual(
      messageHash,
      calculatedMessageHash,
      'Incorrect Message hash.',
    );

    assert.isOk(
      afterSenderUtilityTokenBalance.eq(
        beforeSenderUtilityTokenBalance.sub(withdrawParam.amount),
      ),
      'Withdrawal amount must be transferred from withdrawer.'
        + ` Expected balance is ${beforeSenderUtilityTokenBalance
          .sub(withdrawParam.amount)
          .toString(10)} but`
        + `found ${afterSenderUtilityTokenBalance.toString(10)}`,
    );
  });
});
