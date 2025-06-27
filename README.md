# Crowdfunding Smart Contract

This project implements a basic crowdfunding platform using Solidity. It allows users to create fundraising campaigns, contribute Ether (ETH), claim raised funds if the campaign succeeds, and request refunds if the campaign fails. Additionally, users can create and manage personal profiles to track their participation in the system.

---

## Features

### Campaign Management

- **Campaign Creation**  
  Users can create a new campaign by specifying:
  - `title`: Campaign name  
  - `goal`: Fundraising goal in wei  
  - `durationInDays`: Duration of the campaign  
  - `category`: Enum representing the type of campaign (e.g., Tech, Art, Health)

- **Donation (Contribution)**  
  Any user can contribute ETH to an active campaign using the `donate()` function. Contributions are only accepted while the campaign is active (before its deadline).

- **Claiming Funds**  
  If a campaign reaches or exceeds its goal by the deadline, the owner can claim the total amount using `claimFunds()`.

- **Refunds**  
  If the campaign fails to meet its goal by the deadline, contributors can reclaim their donations using `refund()`.

---

### User Profile Management

- **Create Profile**  
  Users can create a profile with `createProfile(name, bio, contact)` which includes their display name, bio, and contact information. Each user may only create one profile.

- **Update Profile**  
  Existing profiles can be updated using `updateProfile(name, bio, contact)`.

- **Track Donations**  
  The system tracks each user’s total donations across all campaigns, which is viewable via their profile.

---

## Contract Functions Overview

| Function Name         | Description |
|-----------------------|-------------|
| `createCampaign(...)` | Starts a new campaign with a funding goal, deadline, and category |
| `donate(...)`         | Allows users to contribute ETH to an active campaign |
| `claimFunds(...)`     | Lets campaign owner claim funds if the goal is met after deadline |
| `refund(...)`         | Allows contributors to retrieve funds from a failed campaign |
| `createProfile(...)`  | Creates a new user profile |
| `updateProfile(...)`  | Updates an existing user profile |
| `getMyContribution(...)` | Returns the ETH contributed by the caller to a specific campaign |
| `campaigns(...)`      | Public mapping of campaign details |
| `profiles(...)`       | Public mapping of user profiles |
| `campaignCount`       | Tracks the total number of campaigns created |

---

## Categories Supported

Campaigns can be classified under the following categories:
- `Tech`
- `Startup`
- `Art`
- `Health`
- `Animals`
- `Environment`
- `Other`

---

## How to Test

This smart contract can be tested using the [Remix Ethereum IDE](https://remix.ethereum.org):

1. Open Remix and paste the Solidity code into a new file (e.g., `Crowdfunding.sol`)
2. Compile with Solidity version `^0.8.0`
3. Use the **JavaScript VM** environment to deploy the contract
4. Use the available contract functions to:
   - Create campaigns
   - Donate using the `Value` field (ETH amount)
   - Simulate deadline expiry (using `vm` controls or delays)
   - Claim or refund funds
   - Create and update user profiles

---

## Solidity Concepts Used

- `struct`, `mapping`, and `enum` for data modeling  
- `payable` functions for ETH transactions  
- `block.timestamp` to manage campaign deadlines  
- `require()` for input validation and access control  
- Basic use of events for state transparency

---

## License

This project is open source and available under the MIT License.

