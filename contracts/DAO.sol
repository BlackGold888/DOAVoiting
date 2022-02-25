//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./MyToken.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DAO {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    address public chairPerson;
    address public voteToken;
    uint256 public minimumQuorum;
    uint256 public voitingTimeEnd;

    struct Proposal {
        uint256 id;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 quorumBalance;
        uint256 countUsersVoite;
        uint256 startTime;
        bool isActive;
        address recipient;
    }
    mapping(uint256 => mapping(address => uint256)) usersVoteAmount;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public usersDeposite;

    enum VoteType { VOTEFOR, VOTEAGAINST }

    modifier onlyChairPerson(){
        require(msg.sender == chairPerson, "You don't have permision");
        _;
    }

    constructor(address _chairPerson, address _voteToken, uint256 _minimumQuorum, uint256 _voitingTimeEnd) {
        chairPerson = _chairPerson;
        voteToken = _voteToken;
        minimumQuorum = _minimumQuorum;
        voitingTimeEnd = _voitingTimeEnd;
    }

    function deposit(address _to, uint256 _amount)external virtual {
        MyToken(voteToken).mint(_to, _amount);
        usersDeposite[_to] += _amount;
    }

    function addProposal(address _recipient)external virtual onlyChairPerson{
        uint256 proposalId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        proposals[proposalId] = Proposal(proposalId, 0, 0, 0, 0, block.timestamp, true, _recipient);
    }

    function vote(uint256 _id, uint256 _amount, bool _voteType)external virtual {
        require(proposals[_id].isActive == true, "Proposal is not active");
        require(usersDeposite[msg.sender] > 0, "You need deposite before voting");
        require(usersVoteAmount[_id][msg.sender] < usersDeposite[msg.sender], "You already vote");
        require(usersVoteAmount[_id][msg.sender] + _amount <= usersDeposite[msg.sender], "You can't vote small deposit");

        usersVoteAmount[_id][msg.sender] += _amount;
        proposals[_id].id = _id;

        if(_voteType){
            proposals[_id].votesFor += 1;
        }else{
            proposals[_id].votesAgainst += 1;
        }

        proposals[_id].countUsersVoite += 1;
        proposals[_id].quorumBalance += _amount;
    }

    function finishProposal(uint256 _id, bytes memory _data) external virtual payable returns(bool, bytes memory){
        require(proposals[_id].isActive == true, "Proposal is not active");
        require(proposals[_id].quorumBalance >= minimumQuorum, "Quorum not enaught");
        uint256 _votesFor = (proposals[_id].countUsersVoite * 51) / 100;
        require(proposals[_id].votesFor >= _votesFor, "For finish you need more 51% vote for");
        uint256 timeLeft = block.timestamp - proposals[_id].startTime;
        require(timeLeft > voitingTimeEnd, "Voting time has not ended");
        delete proposals[_id];
        (bool success, bytes memory data) = voteToken.call{value: msg.value, gas: 5000}(_data);
        return (success, data);
    }
}
