// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem
{
    uint256 votingStartTime;
    address chairPerson;
    uint votingTime;
    address proposalWinner;
    uint256  maximumVotes; 
    string PartyName;

    struct Voter
    {
        bool voted ;
        uint104 CNIC;
        string Name;
        address participant;
    }

    struct Proposal
    {
        address delegation;
        uint104 CNIC;
        string partyName;
        uint voteCount;
    }

    mapping(address => Voter) isVoter;
    mapping(address => Proposal) isProposal;

    event RecordVoter(address voter, uint CNIC, bool voted);
    event RecordDelegation(address delegation, string partyName, uint voteCount);


    modifier votingAllowed() 
    {
        require(block.timestamp < votingTime + votingStartTime,"Voting time Ended");
        _;
    }

    modifier onlyChairPerson()
    {
        require(msg.sender == chairPerson, "You are not the chair Person");
        _;
    }

    constructor (address _chairperson) 
    {
        require(_chairperson != address(0), "Invalid address");
        chairPerson = _chairperson;
        votingTime = block.timestamp * 1 days;

    }

    function startVoting() external onlyChairPerson 
    {
        require(votingStartTime == 0, "Voting already started");
        votingStartTime = block.timestamp;
    }

    function addDelegations(uint104 _CNIC, string memory _partyName, address _delegation) public onlyChairPerson
    {
        require(votingStartTime == 0, "Voting already started");
        require(_delegation != chairPerson, "Chairmen cannot add itself in delegation");
        require(msg.sender != address(0), "Invalid address");
        require(isProposal[_delegation].delegation != _delegation, "Address is already registered");

        isProposal[_delegation].delegation = _delegation;
        isProposal[_delegation].CNIC = _CNIC;
        isProposal[_delegation].partyName = _partyName;
        isProposal[_delegation].voteCount = 0;


        emit RecordDelegation(_delegation, _partyName, 0);

    }

    function Voting(string memory _name, uint104 _cnic, address candidate) external votingAllowed
    {
        Voter storage voting = isVoter[msg.sender];

        require(voting.voted == false,"Already voted");
        require(msg.sender != chairPerson, "Caller is the chair person");
        require(isProposal[candidate].delegation == candidate, "candidate is not registered");
 
            voting.CNIC = _cnic;
            voting.Name = _name;
            voting.participant = msg.sender;
            voting.voted = true;
            isProposal[candidate].voteCount++;

            updateWinner(candidate);

        emit RecordVoter(msg.sender, _cnic, true);
        
    }

    function updateWinner(address candidate) internal
    {
        maximumVotes = 0;
        uint candidateVotes = isProposal[candidate].voteCount;

        if (candidateVotes > maximumVotes) 
        {
            maximumVotes = candidateVotes;
            proposalWinner = candidate;
            PartyName = isProposal[candidate].partyName;
        }

    }

       function getWinner() external view returns (address, uint,string memory) {
        require(votingStartTime > 0, "Voting has not started yet");
        require(block.timestamp > votingTime, "Voting is not ended yet");
        return (proposalWinner, maximumVotes,PartyName);
    }
}

