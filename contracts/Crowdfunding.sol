// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ---------- IMPORTS ----------
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// ---------- ERRORS ----------
// (None defined currently; you can add custom errors here for gas optimization)

// ---------- INTERFACES, LIBRARIES, CONTRACTS ----------
// (None external, only this contract)

// ---------- TYPE DECLARATIONS ----------
contract Crowdfunding is ReentrancyGuard {

    // ---------- ENUMS ----------
    enum Category {
        Tech,
        Startup,
        Art,
        Health,
        Animals,
        Environment,
        Other
    }

    // ---------- STATE VARIABLES ----------
    uint public campaignCount = 0;

    struct Campaign {
        address owner;
        uint goal;
        uint deadline;
        string title;
        uint amountRaised;
        bool fundsClaimed;
        Category category;
    }

    struct Profile {
        string name;
        string bio;
        string contact;
        uint totalDonated;
        bool created;
    }

    struct Request {
        string description;
        address payable recipient;
        uint value;
        bool complete;
        uint approvalCount;
        // Note: mapping inside structs can’t be returned in view functions
    }

    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public contributions;
    mapping(address => Profile) public profiles;
    mapping(uint => Request[]) private campaignRequests;
    mapping(uint => mapping(uint => mapping(address => bool))) private approvals;
    mapping(uint => uint) public contributorsCount;
    mapping(uint => mapping(address => bool)) public isContributor;

    // ---------- EVENTS ----------
    event CampaignCreated(uint campaignId, address owner, string title);
    event Donated(uint campaignId, address donor, uint amount);
    event FundsWithdrawn(uint campaignId, uint amount);
    event Refunded(uint campaignId, address donor, uint amount);
    event ProfileCreated(address user, string name);
    event ProfileUpdated(address user, string name);
    event RequestCreated(uint campaignId, uint requestIndex, string description);
    event RequestApproved(uint campaignId, uint requestIndex, address approver);
    event RequestFinalized(uint campaignId, uint requestIndex, uint value);

    // ---------- MODIFIERS ----------
    modifier validCampaign(uint _campaignId) {
        require(_campaignId > 0 && _campaignId <= campaignCount, "Invalid campaign ID");
        _;
    }

    // ---------- CONSTRUCTOR ----------
    // (None needed currently)

    // ---------- RECEIVE / FALLBACK FUNCTIONS ----------
    // (None needed currently)

    // ---------- EXTERNAL FUNCTIONS ----------
    // (Could mark functions external if desired, though Solidity defaults to public)

    function createCampaign(
        string memory _title,
        uint _goal,
        uint _durationDays,
        Category _category
    ) public {
        campaignCount++;
        campaigns[campaignCount] = Campaign({
            owner: msg.sender,
            goal: _goal,
            deadline: block.timestamp + (_durationDays * 1 days),
            title: _title,
            amountRaised: 0,
            fundsClaimed: false,
            category: _category
        });

        emit CampaignCreated(campaignCount, msg.sender, _title);
    }

    // ---------- PUBLIC FUNCTIONS ----------
    function donate(uint _campaignId) public payable nonReentrant validCampaign(_campaignId) {
        require(msg.value > 0, "Donation must be more than 0");
        Campaign storage c = campaigns[_campaignId];
        require(block.timestamp < c.deadline, "Campaign ended");

        c.amountRaised += msg.value;

        if(!isContributor[_campaignId][msg.sender]) {
            isContributor[_campaignId][msg.sender] = true;
            contributorsCount[_campaignId]++;
        }
        contributions[_campaignId][msg.sender] += msg.value;
        if (profiles[msg.sender].created) {
            profiles[msg.sender].totalDonated += msg.value;
        }
        emit Donated(_campaignId, msg.sender, msg.value);
    }

    function createProfile(
        string memory _name, 
        string memory _bio, 
        string memory _contact
    ) public {
        require(!profiles[msg.sender].created, "Profile already exists");
        profiles[msg.sender] = Profile({
            name: _name,
            bio: _bio,
            contact: _contact,
            totalDonated: 0,
            created: true
        });
        emit ProfileCreated(msg.sender, _name);
    }

    function updateProfile(
        string memory _name, 
        string memory _bio, 
        string memory _contact
    ) public {
        require(profiles[msg.sender].created, "No profile yet");
        profiles[msg.sender].name = _name;
        profiles[msg.sender].bio = _bio;
        profiles[msg.sender].contact = _contact;
        emit ProfileUpdated(msg.sender, _name);
    }

    function claimFunds(uint _campaignId) public nonReentrant validCampaign(_campaignId) {
        Campaign storage c = campaigns[_campaignId];
        require(msg.sender == c.owner, "Not campaign owner");
        require(block.timestamp >= c.deadline, "Wait for deadline");
        require(c.amountRaised >= c.goal, "Goal not reached");
        require(!c.fundsClaimed, "Already claimed");

        c.fundsClaimed = true; // Effect before interaction
        payable(msg.sender).transfer(c.amountRaised); // Interaction
        emit FundsWithdrawn(_campaignId, c.amountRaised);
    }

    function refund(uint _campaignId) public nonReentrant validCampaign(_campaignId) {
        Campaign storage c = campaigns[_campaignId];
        require(block.timestamp >= c.deadline, "Campaign still active");
        require(c.amountRaised < c.goal, "Goal was met");

        uint donated = contributions[_campaignId][msg.sender];
        require(donated > 0, "No donation found");

        contributions[_campaignId][msg.sender] = 0; // effect
        payable(msg.sender).transfer(donated);
        if (profiles[msg.sender].created) {
            profiles[msg.sender].totalDonated -= donated;
        }
        emit Refunded(_campaignId, msg.sender, donated);
    }

    function createRequest(
        uint _campaignId,
        string memory _description,
        address payable _recipient,
        uint _value
    ) public validCampaign(_campaignId) {
        Campaign storage c = campaigns[_campaignId];
        require(msg.sender == c.owner, "Only campaign owner can create request");
        require(c.amountRaised >= _value, "Requested value exceeds funds raised");

        campaignRequests[_campaignId].push(
            Request({
                description: _description,
                recipient: _recipient,
                value: _value,
                complete: false,
                approvalCount: 0
            })
        );
        emit RequestCreated(_campaignId, campaignRequests[_campaignId].length - 1, _description);
    }

    function approveRequest(uint _campaignId, uint _requestIndex) public validCampaign(_campaignId) {
        require(contributions[_campaignId][msg.sender] > 0, "Must be contributor to approve");
        require(!approvals[_campaignId][_requestIndex][msg.sender], "Already approved this request");

        approvals[_campaignId][_requestIndex][msg.sender] = true;
        Request storage request = campaignRequests[_campaignId][_requestIndex];
        request.approvalCount += 1;
        emit RequestApproved(_campaignId, _requestIndex, msg.sender);
    }

    function finalizeRequest(uint _campaignId, uint _requestIndex) public nonReentrant validCampaign(_campaignId) {
        Campaign storage c = campaigns[_campaignId];
        Request storage request = campaignRequests[_campaignId][_requestIndex];

        require(msg.sender == c.owner, "Only campaign owner can finalize");
        require(!request.complete, "Request already completed");
        require(request.approvalCount > (contributorsCount[_campaignId] / 2), "Not enough approvals");
        require(c.amountRaised >= request.value, "Not enough funds");

        request.complete = true; // Effect before interaction
        c.amountRaised -= request.value;
        request.recipient.transfer(request.value); // Interaction

        emit RequestFinalized(_campaignId, _requestIndex, request.value);
        emit FundsWithdrawn(_campaignId, request.value);
    }

    // ---------- INTERNAL FUNCTIONS ----------
    // (None currently)

    // ---------- PRIVATE FUNCTIONS ----------
    // (None currently)

    // ---------- VIEW & PURE FUNCTIONS ----------
    function getMyContribution(uint _campaignId) public view validCampaign(_campaignId) returns (uint) {
        return contributions[_campaignId][msg.sender];
    }

    function getRequestCount(uint _campaignId) public view validCampaign(_campaignId) returns (uint) {
        return campaignRequests[_campaignId].length;
    }

    function getRequest(
        uint _campaignId,
        uint _index
    )
        public
        view
        validCampaign(_campaignId)
        returns (
            string memory description,
            address recipient,
            uint value,
            bool complete,
            uint approvalCount
        )
    {
        Request storage request = campaignRequests[_campaignId][_index];
        return (
            request.description,
            request.recipient,
            request.value,
            request.complete,
            request.approvalCount
        );
    }
}
