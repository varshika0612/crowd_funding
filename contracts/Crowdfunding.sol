// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    
    enum Category {
        Tech, 
        Startup, 
        Art, 
        Health, 
        Animals, 
        Environment, 
        Other
    }

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

    uint public campaignCount = 0;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public contributions;
    mapping(address => Profile) public profiles;

    // Events
    event CampaignCreated(uint campaignId, address owner, string title);
    event Donated(uint campaignId, address donor, uint amount);
    event FundsWithdrawn(uint campaignId, uint amount);
    event Refunded(uint campaignId, address donor, uint amount);
    event ProfileCreated(address user, string name);
    event ProfileUpdated(address user, string name);

    // Create a fundraising campaign
    function createCampaign(string memory _title, uint _goal, uint _durationDays, Category _category) public {
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

    // Donate to a campaign
    function donate(uint _campaignId) public payable {
        require(msg.value > 0, "Donation must be more than 0");
        Campaign storage c = campaigns[_campaignId];
        require(block.timestamp < c.deadline, "Campaign ended");

        c.amountRaised += msg.value;
        contributions[_campaignId][msg.sender] += msg.value;

        if (profiles[msg.sender].created) {
            profiles[msg.sender].totalDonated += msg.value;
        }

        emit Donated(_campaignId, msg.sender, msg.value);
    }

    // Claim funds after success
    function claimFunds(uint _campaignId) public {
        Campaign storage c = campaigns[_campaignId];
        require(msg.sender == c.owner, "Not campaign owner");
        require(block.timestamp >= c.deadline, "Wait for deadline");
        require(c.amountRaised >= c.goal, "Goal not reached");
        require(!c.fundsClaimed, "Already claimed");

        c.fundsClaimed = true;
        payable(msg.sender).transfer(c.amountRaised);

        emit FundsWithdrawn(_campaignId, c.amountRaised);
    }

    // Get refund if campaign failed
    function refund(uint _campaignId) public {
        Campaign storage c = campaigns[_campaignId];
        require(block.timestamp >= c.deadline, "Campaign still active");
        require(c.amountRaised < c.goal, "Goal was met");

        uint donated = contributions[_campaignId][msg.sender];
        require(donated > 0, "No donation found");

        contributions[_campaignId][msg.sender] = 0;
        payable(msg.sender).transfer(donated);

        if (profiles[msg.sender].created) {
            profiles[msg.sender].totalDonated -= donated;
        }

        emit Refunded(_campaignId, msg.sender, donated);
    }

    // Create a user profile
    function createProfile(string memory _name, string memory _bio, string memory _contact) public {
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

    // Update existing profile
    function updateProfile(string memory _name, string memory _bio, string memory _contact) public {
        require(profiles[msg.sender].created, "No profile yet");

        profiles[msg.sender].name = _name;
        profiles[msg.sender].bio = _bio;
        profiles[msg.sender].contact = _contact;

        emit ProfileUpdated(msg.sender, _name);
    }

    // View contribution amount
    function getMyContribution(uint _campaignId) public view returns (uint) {
        return contributions[_campaignId][msg.sender];
    }
}
