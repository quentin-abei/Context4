// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOMembership {

    address public owner;
    uint256 public noMembers;

    constructor(address _owner) {
        owner = _owner;
        members[owner] = true;
        noMembers ++;
    }

    mapping(address => bool) public members;
    mapping(address => uint) public noOfApplication;
    mapping(address => uint) public approvals;

    //To apply for membership of DAO
    function applyForEntry() public {
        require(!members[msg.sender], "you are already a member");
        require(noOfApplication[msg.sender] == 0, "You have already applied");
        noOfApplication[msg.sender] += 1;
    }
    
    //To approve the applicant for membership of DAO
    function approveEntry(address _applicant) public onlyMembers {
        require(noOfApplication[_applicant] > 0, "This address have not applied");
        require(!members[_applicant], "already a member");
        uint treshold = (noMembers*30)/100;
        if(approvals[_applicant] >= treshold){
            members[_applicant] = true;
        }
        
        approvals[_applicant] += 1;
        noMembers++;
    }

    //To check membership of DAO
    function isMember(address _user) public view onlyMembers returns (bool) {
        return members[_user];
    }

    //To check total number of members of the DAO
    function totalMembers() public view onlyMembers returns (uint256) {
        return noMembers;
    }

    modifier onlyMembers() {
         require(members[msg.sender], "Not allowed");
         _;
    }
}
