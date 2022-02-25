import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { expect } from "chai";
import { Contract, ContractFactory, ContractReceipt } from "ethers";
import { ethers, network } from "hardhat";

describe("DAO", function () {
  let MyToken: ContractFactory;
  let DAOContract: ContractFactory;
  let daoContractInstance: Contract;
  let hardhatToken: Contract;
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
  let addr2: SignerWithAddress;
  const data = require('./MyToken.json');

  beforeEach(async function () {
    MyToken = await ethers.getContractFactory("MyToken");
    hardhatToken = await MyToken.deploy();
    await hardhatToken.deployed();
    // Get the ContractFactory and Signers here.
    DAOContract = await ethers.getContractFactory("DAO");
    [owner, addr1, addr2] = await ethers.getSigners();
    daoContractInstance = await DAOContract.deploy(owner.address, hardhatToken.address, 100, 600);
    await daoContractInstance.deployed();
    hardhatToken.transferOwnership(daoContractInstance.address);
  });

  it("Deposit", async function () {
    await daoContractInstance.deposit(addr1.address, ethers.utils.parseEther('100')); 
    expect(await daoContractInstance.usersDeposite(addr1.address)).to.equal(ethers.utils.parseEther('100'));
  });

  it("addProposal", async function () {
    await daoContractInstance.addProposal(owner.address); 
    const res = await daoContractInstance.proposals(0);
    expect(res.isActive).to.equal(true);
  });

  it("Vote", async function () {
    await daoContractInstance.addProposal(owner.address); 
    await daoContractInstance.deposit(addr1.address, ethers.utils.parseEther('100')); 
    await daoContractInstance.connect(addr1).vote(0, ethers.utils.parseEther('100'), true); // If true you voiting for
    const res = await daoContractInstance.proposals(0);
    expect(res.isActive).to.equal(true);
    expect(res.quorumBalance).to.equal(ethers.utils.parseEther('100'));
    expect(res.votesFor).to.equal(1);
  });

  it.only("Finish proposals", async function () {
    await daoContractInstance.addProposal(owner.address); 
    await daoContractInstance.deposit(addr1.address, ethers.utils.parseEther('100')); 
    await daoContractInstance.deposit(addr2.address, ethers.utils.parseEther('100')); 
    await daoContractInstance.connect(addr1).vote(0, ethers.utils.parseEther('100'), true); // If true you voiting for
    await daoContractInstance.connect(addr2).vote(0, ethers.utils.parseEther('100'), true); // If true you voiting for
    let iface = new ethers.utils.Interface(data.abi);
    const temp = await iface.encodeFunctionData("mint", [owner.address, ethers.utils.parseEther('100')]);
    console.log(temp);
    await network.provider.send("evm_increaseTime", [600]);
    
    const res = await daoContractInstance.finishProposal(0, temp);
    console.log(res);
    const proposalResult = await daoContractInstance.proposals(0);
    console.log(proposalResult);
    
      // expect(await hardhatToken.balanceOf(owner.address)).to.equal(ethers.utils.parseEther('100'));
  });
});