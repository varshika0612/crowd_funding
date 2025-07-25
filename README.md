# Crowdfunding Smart Contract

This repository contains a Solidity smart contract for a decentralized crowdfunding platform. The contract enables users to create fundraising campaigns, contribute Ether (ETH), track their donations, claim funds upon campaign success, and request refunds in case of failure. It also supports user profiles for an engaging and personalized experience.

## Features

### Campaign Management

- **Create Campaign**
  - Users can launch new fundraising campaigns with:
    - `title`: Campaign name  
    - `goal`: Target amount in wei  
    - `durationInDays`: Campaign duration (in days)  
    - `category`: Enum for campaign classification (Tech, Art, Health, etc.)

- **Donate**
  - Any address can contribute ETH to an active campaign using the `donate()` function.
  - Contributions are only possible before the campaign’s deadline.

- **Claim Funds**
  - If a campaign meets or surpasses its goal before the deadline, the owner can withdraw all raised funds via `claimFunds()`.

- **Refunds**
  - If the campaign does not reach its goal by the deadline, contributors can get their ETH back using `refund()`.

### Spending Requests & Governance

- **Create Spending Requests**
  - Campaign owners may submit requests to spend raised funds, specifying a description, recipient, and amount.

- **Approval by Contributors**
  - Contributors vote to approve or reject spending requests.
  - Funds are only released if more than 50% of contributors approve a request.

### User Profile Management

- **Create Profile**
  - Each user can create a profile (`createProfile(name, bio, contact)`), containing their display name, short bio, and contact details.

- **Update Profile**
  - User profiles can be updated any time via `updateProfile(name, bio, contact)`.

- **Donation Tracking**
  - The smart contract tracks each user's total donations across all campaigns for transparency and personal stats.

## Main Contract Functions

| Function Name              | Purpose/Action                                                      |
|----------------------------|---------------------------------------------------------------------|
| `createCampaign(...)`      | Launch a new fundraising campaign                                   |
| `donate(...)`              | Contribute ETH to an active campaign                               |
| `claimFunds(...)`          | Owner claims funds post-deadline if the goal is met                |
| `refund(...)`              | Contributor reclaims donation if the campaign fails                |
| `createProfile(...)`       | Register a personal user profile                                   |
| `updateProfile(...)`       | Modify profile metadata                                            |
| `getMyContribution(...)`   | Check ETH contributed by caller to a campaign                      |
| `campaigns(...)`           | Public mapping of campaign data                                    |
| `profiles(...)`            | Public mapping of user profiles                                    |
| `campaignCount`            | Counter for campaigns created                                      |
| `createRequest(...)`       | Campaign owner submits a spending request                          |
| `approveRequest(...)`      | Contributor votes to approve a spending request                    |
| `finalizeRequest(...)`     | Campaign owner finalizes and executes approved spending requests   |

## Campaign Categories

Fundraisers are organized into the following categories:
- Tech  
- Startup  
- Art  
- Health  
- Animals  
- Environment  
- Other

## How To Test

You can test this contract using the [Remix Ethereum IDE](https://remix.ethereum.org):

1. Paste the Solidity code into `Crowdfunding.sol` in a new Remix project.
2. Compile using Solidity version `^0.8.0` (select in compiler settings).
3. Deploy the contract in the **JavaScript VM** environment.
4. Use the contract’s public UI to:
   - Launch new campaigns
   - Donate ETH (set Value and call `donate`)
   - Wait for/block deadline expiration to simulate end of campaign
   - Claim or refund funds as appropriate
   - Create and update user profiles
   - Submit and approve spending requests

## Solidity Concepts Demonstrated

- Use of `struct`, `enum`, and `mapping` for data modeling
- `payable` functions for Ether transfer
- Block timestamps (`block.timestamp`) to control campaign timelines
- Modifiers for access, deadlines, and input validation
- Secure coding patterns (e.g., reentrancy guards with OpenZeppelin)
- Events for off-chain monitoring and transparency

## License

This project is licensed under the MIT License. You may use, modify, and distribute it freely for personal or commercial projects.
