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
//
// ----------------------------------------------------------------------------
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------
import {Axiom} from "../interacts/Axiom";
import {Committee} from "../interacts/Committee";
import {Consensus} from "../interacts/Consensus";
import {Core} from "../interacts/Core";
import {Reputation} from "../interacts/Reputation";
import {EIP20Token} from "../interacts/EIP20Token";
import {Anchor} from "../interacts/Anchor";

const Web3 = require("web3");

const web3 = new Web3('http://localhost:8545');
// For testing use 1 block confirmation.
web3.transactionConfirmationBlocks = 1;

/**
 * An object that is shared across modules.
 *
 * @property {Object} artifacts The truffle artifacts of the contracts. Indexed
 *     by the contract name, as written in the solidity source
 *     file.
 */


class ContractEntity {
  address: string;
  instance: any;

  constructor() {
  }
}

class Contract {
  public Axiom: Axiom;

  public Committee: Committee;

  public Consensus: Consensus;

  public Core: Core;

  public Reputation: Reputation;

  public Anchor: Anchor;

  public MOST: EIP20Token;

  public WETH: EIP20Token;

  constructor() {
  }

}

class Origin {
  public funder: string;
  public web3: any;
  public keys: {
    techGov: string;
    validators: string[];
  };

  public contracts: Contract;

  constructor() {
    this.keys = {
      techGov: '',
      validators: [],
    };

    this.contracts = new Contract();
    this.web3 = web3;
  }

}

class Shared {
  public artifacts: any;
  public origin: Origin;

  constructor() {
    this.artifacts = {};
    this.origin =  new Origin();
  }
}

export default new Shared();
