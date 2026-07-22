# Notary — Proof of Existence dApp

A beginner blockchain project: users drop in a file, its SHA-256 fingerprint
is computed **in their browser** (the file itself is never uploaded anywhere),
and that fingerprint is timestamped permanently on the blockchain. Anyone can
later re-check the same file against the on-chain record to prove it existed
at a specific point in time.

Runs on **Sepolia**, Ethereum's free test network — no real money involved.

## Files
- `ProofOfExistence.sol` — the smart contract (stores hash → submitter, timestamp, label)
- `index.html` — the entire frontend (HTML/CSS/JS in one file, no build step needed)

---

## Step 1 — Deploy the smart contract (5 minutes, all in-browser)

1. Go to **[remix.ethereum.org](https://remix.ethereum.org)**
2. Create a new file called `ProofOfExistence.sol` and paste in the contract code
3. Left sidebar → **Solidity Compiler** → click **Compile ProofOfExistence.sol**
4. Left sidebar → **Deploy & Run Transactions**
   - Environment: choose **"Injected Provider - MetaMask"**
   - Make sure MetaMask is switched to the **Sepolia test network** (toggle "show test networks" in MetaMask's network list if you don't see it)
   - If you have no test ETH yet, grab some free from **[sepoliafaucet.com](https://sepoliafaucet.com)** or **[Alchemy's Sepolia faucet](https://www.alchemy.com/faucets/ethereum-sepolia)** — just paste your wallet address
5. Click **Deploy**, confirm the transaction in MetaMask
6. Once deployed, copy the **contract address** shown under "Deployed Contracts" — you'll need it next

## Step 2 — Connect the frontend to your contract

Open `index.html` and find this block near the top of the `<script>` section:

```javascript
const CONTRACT_ADDRESS = "0xYOUR_DEPLOYED_CONTRACT_ADDRESS";
```

Replace it with the address you copied from Remix. Save the file.
(The ABI is already filled in to match the contract as written — if you
change the contract's functions, update the ABI array to match.)

## Step 3 — Deploy the frontend so anyone can use it

Easiest path — **Netlify drag-and-drop**:
1. Go to **[app.netlify.com/drop](https://app.netlify.com/drop)**
2. Drag the folder containing `index.html` onto the page
3. Netlify gives you a live public URL in seconds — done

Alternative — **Vercel** (good if you want git-based auto-deploys):
1. Push this folder to a new GitHub repo
2. Go to **[vercel.com/new](https://vercel.com/new)**, import the repo
3. Framework preset: "Other" (it's a static file, no build needed)
4. Deploy — you get a public `.vercel.app` URL

Either way, share the resulting URL. Anyone with a browser and MetaMask
(with a little free Sepolia ETH) can now notarize or verify files through
your site.

## How it works, in short

- **Notarize tab**: user drops a file → browser computes its SHA-256 hash →
  wallet prompts to confirm a transaction → the hash (not the file) is
  stored on-chain forever, alongside the submitter's address and a timestamp.
- **Verify tab**: user drops a file (or pastes a known hash) → the app reads
  the on-chain record for that hash and shows who notarized it and when, or
  confirms no record exists.

## Ideas to extend it later
- Show a live list of recent notarizations by listening for the `Notarized` event
- Let users attach a short public note/description alongside the hash
- Add support for notarizing multiple files as a single "batch" transaction
- Deploy to Ethereum mainnet or a cheaper L2 (e.g. Base, Arbitrum) once you're
  ready to move past the test network — note this involves *real* funds for gas
