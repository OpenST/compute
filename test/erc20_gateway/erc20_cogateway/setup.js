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

const BN = require('bn.js');
const Utils = require('../../test_lib/utils.js');
const { AccountProvider } = require('../../test_lib/utils.js');
const ConsensusGatewayUtils = require('../../consensus-gateway/utils');

const ERC20Cogateway = artifacts.require('ERC20CogatewayDouble');

contract('ERC20Cogateway::setup', (accounts) => {
  const accountProvider = new AccountProvider(accounts);
  let erc20Cogateway;
  let setupGenesisParams = {};

  beforeEach(async () => {
    erc20Cogateway = await ERC20Cogateway.new();
    setupGenesisParams = {
      genesisMetachainId: Utils.generateRandomMetachainId(),
      genesisERC20Gateway: accountProvider.get(),
      genesisStateRootProvider: accountProvider.get(),
      genesisMaxStorageRootItems: new BN(100),
      genesisOutboxStorageIndex: new BN(4),
      genesisUtilityTokenMasterCopy: accountProvider.get(),
    };
    await erc20Cogateway.setupGenesis(
      setupGenesisParams.genesisMetachainId,
      setupGenesisParams.genesisERC20Gateway,
      setupGenesisParams.genesisStateRootProvider,
      setupGenesisParams.genesisMaxStorageRootItems,
      setupGenesisParams.genesisOutboxStorageIndex,
      setupGenesisParams.genesisUtilityTokenMasterCopy,
    );
  });

  it('should successfully setup ERC20 cogateway contract', async () => {

    await erc20Cogateway.setup();

    const outboxStorageIndexInContract = await erc20Cogateway.outboxStorageIndex.call();
    assert.isOk(
      setupGenesisParams.genesisOutboxStorageIndex.eq(outboxStorageIndexInContract),
      'Expected outbox storage index is '
      + `${setupGenesisParams.genesisOutboxStorageIndex.toString(10)}`
      + `but got ${outboxStorageIndexInContract.toString(10)}`,
    );

    const stateRootProviderInContract = await erc20Cogateway.stateRootProvider.call();
    assert.strictEqual(
      stateRootProviderInContract,
      setupGenesisParams.genesisStateRootProvider,
      'State root provider address is not set in the contract.',
    );

    const messageInboxAddressFromContract = await erc20Cogateway.messageInbox.call();
    assert.strictEqual(
      messageInboxAddressFromContract,
      setupGenesisParams.genesisERC20Gateway,
      'Inbox address is not set in the contract.',
    );

    const messageOutboxAddressFromContract = await erc20Cogateway.messageOutbox.call();
    assert.strictEqual(
      messageOutboxAddressFromContract,
      setupGenesisParams.genesisERC20Gateway,
      'Outbox address is not set in the contract.',
    );

    const outboundChannelIdentifier = ConsensusGatewayUtils.getChannelIdentifier(
      setupGenesisParams.genesisMetachainId,
      erc20Cogateway.address,
      setupGenesisParams.genesisERC20Gateway,
    );
    const outboundChannelIdentifierInContract = await erc20Cogateway.outboundChannelIdentifier
      .call();
    assert.strictEqual(
      outboundChannelIdentifier,
      outboundChannelIdentifierInContract,
      'Invalid outbound channel identifier.',
    );

    const inboundChannelIdentifier = ConsensusGatewayUtils.getChannelIdentifier(
      setupGenesisParams.genesisMetachainId,
      setupGenesisParams.genesisERC20Gateway,
      erc20Cogateway.address,
    );
    const inboundChannelIdentifierInContract = await erc20Cogateway.inboundChannelIdentifier
      .call();
    assert.strictEqual(
      inboundChannelIdentifier,
      inboundChannelIdentifierInContract,
      'Invalid inbound channel identifier.',
    );
  });
});
