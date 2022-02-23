//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./MyToken.sol";

contract DAO {
    address public chairPerson;
    address public voteToken;
    uint256 public minimumQuorum;
    uint256 public voitingTimeEnd;

    struct Proposal {
        uint256 id;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 quorumBalance;
        bool isActive;
    }

    mapping(uint256 => Proposal) public proposals;

    struct User {
        address client;
        uint256 balance;
    }

    constructor(address _chairPerson, address _voteToken, uint256 _minimumQuorum, uint256 _voitingTimeEnd) {
        chairPerson = _chairPerson;
        voteToken = _voteToken;
        minimumQuorum = _minimumQuorum;
        voitingTimeEnd = _voitingTimeEnd;
    }

    function deposit(address _to, uint256 _amount)external virtual {
        MyToken(voteToken).mint(_to, _amount);        
    }

    function addProposal(address _recipient, string memory _description)external virtual{
        //Some code
    }

    function vote(uint256 _amount)external virtual {
        //some code
    }

    function finishProposal(uint256 _id) external virtual {
        require(proposals[_id].isActive == true, "Proposal not active");
    }
}
