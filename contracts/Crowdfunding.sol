// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Errors
error Crowdfunding__DeadlineNotReached();
error Crowdfunding__GoalAlreadyMet();
error Crowdfunding__NotCampaignOwner();
error Crowdfunding__CampaignEnded();
error Crowdfunding__InvalidContribution();
error Crowdfunding__NoContributionFound();
error Crowdfunding__FundsAlreadyClaimed();
error Crowdfunding__TransferFailed();
error Crowdfunding__ProfileAlreadySet();
error Crowdfunding__ProfileNotSet();

contract Crowdfunding {
    // Type declarations
    struct Campaign {
        address owner;
        uint256 goal;
        uint256 deadline;
        string title;
        uint256 totalFunds;
        bool fundsClaimed;
        mapping(address => uint256) contributions;
    }

    struct UserProfile {
        string displayName;
        string bio;
        string contact;
        bool exists;
    }

    // State variables
    uint256 private s_campaignCount;
    mapping(uint256 => Campaign) private s_campaigns;
    mapping(address => UserProfile) private s_userProfiles;

    // Events
    event CampaignCreated(uint256 indexed campaignId, address owner, string title);
    event Contributed(uint256 indexed campaignId, address contributor, uint256 amount);
    event FundsClaimed(uint256 indexed campaignId, uint256 amount);
    event Refunded(uint256 indexed campaignId, address contributor, uint256 amount);
    event ProfileUpdated(address indexed user, string displayName);

    // Modifiers
    modifier onlyOwner(uint256 campaignId) {
        if (msg.sender != s_campaigns[campaignId].owner) 
            revert Crowdfunding__NotCampaignOwner();
        _;
    }

    modifier activeCampaign(uint256 campaignId) {
        if (block.timestamp >= s_campaigns[campaignId].deadline) 
            revert Crowdfunding__CampaignEnded();
        _;
    }

    modifier profileNotSet() {
        if (s_userProfiles[msg.sender].exists) 
            revert Crowdfunding__ProfileAlreadySet();
        _;
    }

    // External functions
    function createCampaign(
        uint256 _goal,
        uint256 _durationInDays,
        string memory _title
    ) external {
        require(_durationInDays > 0, "Duration must be >0 days");
        
        s_campaignCount++;
        Campaign storage newCampaign = s_campaigns[s_campaignCount];
        
        newCampaign.owner = msg.sender;
        newCampaign.goal = _goal;
        newCampaign.deadline = block.timestamp + (_durationInDays * 1 days);
        newCampaign.title = _title;
        
        emit CampaignCreated(s_campaignCount, msg.sender, _title);
    }

    function contribute(uint256 campaignId) 
        external 
        payable 
        activeCampaign(campaignId) 
    {
        Campaign storage campaign = s_campaigns[campaignId];
        
        if (msg.value == 0) revert Crowdfunding__InvalidContribution();
        
        campaign.totalFunds += msg.value;
        campaign.contributions[msg.sender] += msg.value;
        
        emit Contributed(campaignId, msg.sender, msg.value);
    }

    // Public functions
    function setUserProfile(
        string memory _displayName,
        string memory _bio,
        string memory _contact
    ) public profileNotSet {
        s_userProfiles[msg.sender] = UserProfile({
            displayName: _displayName,
            bio: _bio,
            contact: _contact,
            exists: true
        });
        emit ProfileUpdated(msg.sender, _displayName);
    }

    function updateUserProfile(
        string memory _displayName,
        string memory _bio,
        string memory _contact
    ) public {
        if (!s_userProfiles[msg.sender].exists) 
            revert Crowdfunding__ProfileNotSet();
            
        s_userProfiles[msg.sender] = UserProfile({
            displayName: _displayName,
            bio: _bio,
            contact: _contact,
            exists: true
        });
        emit ProfileUpdated(msg.sender, _displayName);
    }

    function claimFunds(uint256 campaignId) public onlyOwner(campaignId) {
        Campaign storage campaign = s_campaigns[campaignId];
        
        if (block.timestamp < campaign.deadline) 
            revert Crowdfunding__DeadlineNotReached();
        if (campaign.totalFunds < campaign.goal) 
            revert Crowdfunding__GoalAlreadyMet();
        if (campaign.fundsClaimed) 
            revert Crowdfunding__FundsAlreadyClaimed();
        
        campaign.fundsClaimed = true;
        (bool success, ) = payable(msg.sender).call{value: campaign.totalFunds}("");
        if (!success) revert Crowdfunding__TransferFailed();
        
        emit FundsClaimed(campaignId, campaign.totalFunds);
    }

    function getRefund(uint256 campaignId) public {
        Campaign storage campaign = s_campaigns[campaignId];
        
        if (block.timestamp < campaign.deadline) 
            revert Crowdfunding__DeadlineNotReached();
        if (campaign.totalFunds >= campaign.goal) 
            revert Crowdfunding__GoalAlreadyMet();
        
        uint256 amount = campaign.contributions[msg.sender];
        if (amount == 0) revert Crowdfunding__NoContributionFound();
        
        campaign.contributions[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert Crowdfunding__TransferFailed();
        
        emit Refunded(campaignId, msg.sender, amount);
    }

    // View & pure functions
    function getCampaign(uint256 campaignId) 
        public 
        view 
        returns (
            address owner,
            uint256 goal,
            uint256 deadline,
            string memory title,
            uint256 totalFunds,
            bool fundsClaimed
        ) 
    {
        Campaign storage campaign = s_campaigns[campaignId];
        return (
            campaign.owner,
            campaign.goal,
            campaign.deadline,
            campaign.title,
            campaign.totalFunds,
            campaign.fundsClaimed
        );
    }

    function getUserProfile(address user)
        public
        view
        returns (
            string memory displayName,
            string memory bio,
            string memory contact,
            bool exists
        )
    {
        UserProfile storage profile = s_userProfiles[user];
        return (
            profile.displayName,
            profile.bio,
            profile.contact,
            profile.exists
        );
    }

    function getContribution(uint256 campaignId, address contributor) 
        public 
        view 
        returns (uint256) 
    {
        return s_campaigns[campaignId].contributions[contributor];
    }

    function getCampaignCount() public view returns (uint256) {
        return s_campaignCount;
    }
}
