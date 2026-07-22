# Open Ballot — On-Chain Voting / Poll dApp

Anyone can create a poll with a question and 2-8 options. Anyone with a wallet
can vote — one vote per wallet address, per poll. Results are public and
tamper-proof: once cast, a vote can't be changed or deleted by anyone,
including the poll's creator.

Runs on **Sepolia**, Ethereum's free test network — no real money involved.

## Files
- `OpenBallot.sol` — the smart contract (create polls, cast votes, read results)
- `index.html` — the entire frontend (HTML/CSS/JS in one file, no build step)

---

## Step 1 — Deploy the smart contract (same flow as before)

1. Go to **[remix.ethereum.org](https://remix.ethereum.org)**
2. New file `OpenBallot.sol` → paste in the contract code
3. **Solidity Compiler** tab → Compile
4. **Deploy & Run Transactions** tab:
   - Environment: **Injected Provider - MetaMask**
   - Confirm MetaMask is on **Sepolia** and has a little test ETH (see faucet links below if not)
5. Click **Deploy**, confirm in MetaMask
6. Copy the deployed **contract address**

Faucets if you need test ETH:
- **[Google Cloud Web3 Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)** — no prerequisites
- **[sepolia-faucet.pk910.de](https://sepolia-faucet.pk910.de)** — mine a small amount in-browser
- **[faucets.chain.link](https://faucets.chain.link)**

## Step 2 — Connect the frontend

Open `index.html`, find:

```javascript
const CONTRACT_ADDRESS = "0xYOUR_DEPLOYED_CONTRACT_ADDRESS";
```

Paste in your deployed address. Save.

## Step 3 — Deploy the frontend

**Netlify drag-and-drop** (fastest):
1. **[app.netlify.com/drop](https://app.netlify.com/drop)**
2. Drag the folder containing `index.html` onto the page
3. Get your live public URL immediately

**Vercel** (if you want git-based auto-deploy): push the folder to a GitHub
repo, import it at **vercel.com/new**, framework preset "Other" — deploy.

## How it works

- **Create a poll**: type a question, add 2-8 options, hit publish — this
  writes the poll to the blockchain permanently.
- **Vote**: click an option — a transaction is sent recording your vote.
  The contract blocks a second vote from the same address on the same poll.
- **Results**: vote counts and percentages update live, pulled directly from
  the contract, so anyone visiting the page (with or without a wallet) can
  read the current tally.

## Note on "token-based" voting

This version is **one-wallet-one-vote** — the simplest and most common
pattern for on-chain polls. A stricter "token-weighted" version (where
voting power is proportional to how many of a specific ERC-20 token someone
holds) is a natural next step once you're comfortable with this one:
- Deploy or reference an existing ERC-20 token contract
- In `vote()`, replace the flat `+= 1` with `+= token.balanceOf(msg.sender)`
- Consider a snapshot mechanism (recording balances at poll-creation time)
  so people can't just buy tokens right before voting to swing a result

## Ideas to extend it later
- Add a closing time to each poll (`block.timestamp` deadline) after which
  votes are rejected
- Let the frontend highlight *which* option a user picked, not just that
  they voted (requires storing the chosen index per voter, not just a bool)
- Add categories/tags so polls can be filtered or searched
- Gate poll creation behind holding a specific NFT or token, to reduce spam
