import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { expect } from "chai";
import { Contract, ContractFactory, ContractReceipt } from "ethers";
import { ethers } from "hardhat";

describe("ERC721", function () {
  let Token: ContractFactory;
  let hardhatToken: Contract;
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
  let addr2: SignerWithAddress;
  const data = require('./MyToken.json');

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Token = await ethers.getContractFactory("MyToken");
    [owner, addr1, addr2] = await ethers.getSigners();
    hardhatToken = await Token.deploy();
  });

  it("BalanceOf return token counts", async function () {
      // console.log(data.abi[12]);
      let iface = new ethers.utils.Interface(data.abi);
      const temp = await iface.encodeFunctionData("mint", [owner.address, ethers.utils.parseEther('100')]);
      console.log(temp);
      
      // expect(await hardhatToken.balanceOf(owner.address)).to.equal(ethers.utils.parseEther('100'));
  });
});