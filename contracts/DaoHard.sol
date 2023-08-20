// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOMembership {
    
    address public owner;
    uint256 private noOfMembers;
    uint8 public constant THRESHOLD_PERCENT_APPROVE = 30;
    uint8 public constant THRESHOLD_PERCENT_DISAPPROVE = 70;

    mapping(address => bool) public members;
    mapping(address => Application) public applications;
    mapping(address => Vote) public votes;
    mapping(address => bool) public blacklist;

    error AlreadyApplied(address);

    constructor() {
        owner = msg.sender;
        noOfMembers = 1;
        members[msg.sender] = true;
    }

    struct Application {
        bool applied;
        uint8 maxApply;
        uint256 approvals;
        uint256 disapprovals;
    }

    struct Vote {
        uint256 yes;
    }

    //To apply for membership of DAO
    function applyForEntry() public onlyNonMembers isNotRestricted {
        require(!blacklist[msg.sender], "You are blacklisted");
        if (applications[msg.sender].applied) {
            revert AlreadyApplied(msg.sender);
        }
       applications[msg.sender].applied = true;
       applications[msg.sender].maxApply = 1;
    }
    
    //To approve the applicant for membership of DAO
    function approveEntry(address _applicant) public onlyMembers isNotRestricted {
        Application storage app = applications[_applicant];
        require(app.applied, "Not an applicant");
        app.approvals += 1;
        if(app.approvals >= ((noOfMembers * THRESHOLD_PERCENT_APPROVE)/100)){
            members[_applicant] = true;
            noOfMembers++;
            app.applied = false;
        }
    }

    //To disapprove the applicant for membership of DAO
    function disapproveEntry(address _applicant) public onlyMembers isNotRestricted {
        Application storage appl = applications[_applicant];
        require(appl.applied, "address did not apply");
        appl.disapprovals += 1;
        if(appl.disapprovals >= THRESHOLD_PERCENT_DISAPPROVE){
            appl.applied = false;
        }
    }

    //To remove a member from DAO
    function removeMember(address _memberToRemove) public onlyMembers isNotRestricted {
        require(_memberToRemove != msg.sender, "Operation not allowed");
        require(members[_memberToRemove], "Not a member");
        Vote storage vote = votes[_memberToRemove];
        vote.yes += 1;
        if(vote.yes >= ((noOfMembers*THRESHOLD_PERCENT_DISAPPROVE)/100)){
           members[_memberToRemove] = false;
           blacklist[_memberToRemove] = true;
        }
    }

    //To leave DAO
    function leave() public onlyMembers isNotRestricted {
        members[msg.sender] = false;
        blacklist[msg.sender] = true;
    }

    //To check membership of DAO
    function isMember(address _user) public view onlyMembers isNotRestricted returns (bool)  {
        return members[_user];
    }

    //To check total number of members of the DAO
    function totalMembers() public view onlyMembers isNotRestricted returns (uint256) {
        return noOfMembers;
    }

    modifier onlyNonMembers() {
        require(!members[msg.sender], "Not allowed");
        _;
    }

    modifier onlyMembers() {
        require(members[msg.sender], "Not allowed");
        _;
    }

    modifier isNotRestricted() {
        require(noOfMembers > 0, "smart contract is restricted");
        _;
    }
}
