# 💰 Crowdfunding DApp (Solidity)

This is a simple decentralized crowdfunding smart contract built using **Solidity**. It allows users to create campaigns, donate ETH, manage their profiles, and claim or refund funds based on campaign results.

> 🎓 Made by a college student exploring Ethereum smart contracts.

---

## 🚀 Features

- ✅ Create fundraising campaigns with deadlines and goals  
- 💸 Contribute ETH to any active campaign  
- 🎯 Claim funds if the campaign meets its goal after the deadline  
- 💔 Refund donations if the campaign fails  
- 👤 Create and update user profiles with display name, bio, and contact  
- 📊 Track individual user contributions per campaign  

---

## 🛠️ Tech Stack

| Layer        | Tools Used          |
|-------------|---------------------|
| Smart Contract | Solidity (`^0.8.0`) |
| Development  | Remix IDE / Hardhat |
| Network      | JavaScript VM (Remix) or Localhost/Testnet (Hardhat) |

---

## 🔨 How It Works

### 🧾 Campaign

Each campaign has:
- An owner (creator)
- A funding goal (in wei)
- A deadline (in days)
- A title
- A category (like Tech, Art, Health, etc.)
- Amount of ETH raised
- Status: whether funds were claimed or not

### 🧑‍🤝‍🧑 User Profile

Each user can:
- Create a profile (once)
- Update their profile info (name, bio, contact)
- View how much they’ve donated in total

### ⏰ Contribution & Refund Logic

- If a campaign **ends and reaches its goal**, only the owner can claim the funds.
- If the campaign **fails to meet the goal**, users can request a **refund**.
- Users can only donate before the deadline.

---

## 🧪 How to Test (Remix Quick Start)

1. Go to [https://remix.ethereum.org](https://remix.ethereum.org)
2. Create a new file `Crowdfunding.sol`
3. Paste the contract code
4. Compile it using Solidity `^0.8.0`
5. Deploy using “JavaScript VM” (no wallet needed)
6. Try:
   - `createCampaign()`
   - `donate()` with ETH value
   - `claimFunds()` after time passes
   - `refund()` if goal not met
   - `createProfile()` and `updateProfile()`

---

## 🧠 Learning Goals

✅ Understand how to:
- Use structs, mappings, and enums  
- Handle ETH transfers with `payable`  
- Use time-based logic (`block.timestamp`)  
- Track user state and contributions  
- Write a gas-efficient yet readable contract  

---

## 📸 Screenshots (Optional)

> 📷 Add Remix screenshots of:
> - Creating a campaign
> - Donating
> - Claiming funds
> - Getting refund
> - Setting profile

---

## ✍️ Author

**Varshika Cheemala**  
College Student | Solidity Learner  
✨ Exploring the power of Web3

---

## 📜 License

MIT License – Free to use and modify.
