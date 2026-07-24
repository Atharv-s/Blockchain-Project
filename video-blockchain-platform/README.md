# Blockchain-Gated Video Platform (Starter Project)

A working scaffold for a wallet-gated, time-limited video streaming platform,
built free-of-cost on a public testnet. This matches the architecture you'd
already worked through: the blockchain never stores video — it stores
**permission records** (wallet, videoId, expiry), and a backend "gatekeeper"
checks those records before releasing decryption keys.

## How it fits together

```
Viewer's wallet                Gatekeeper backend              Blockchain (Sepolia)
──────────────                 ───────────────────              ────────────────────
1. GET /challenge  ─────────►  issue nonce + message
2. sign message (free,
   off-chain, no gas)
3. POST /verify    ─────────►  verify signature
                                 │
                                 └── hasAccess(videoId, wallet)?  ──►  read (free)
                                 issue sessionToken
4. player requests
   each HLS segment ─────────►  GET /segment-key
                                 │  re-check session + on-chain
                                 └── hasAccess(...) again          ──►  read (free)
                                 return AES-128 key or 401/403
```

Access is granted by **you** (the platform), not purchased by the viewer:
your own backend wallet calls `grantAccess()` — the only address that ever
pays gas is yours. Viewers never need any ETH, on any network.

## What's included

| Piece | File | What it does |
|---|---|---|
| Access-control contract | `contracts/VideoAccess.sol` | `grantAccess`, `revokeAccess`, `hasAccess` — the on-chain permission registry |
| Deployment script | `scripts/deploy.js` | Deploys to Sepolia (or any EVM testnet) |
| Contract tests | `test/VideoAccess.test.js` | Grant / revoke / access-denied cases |
| Gatekeeper server | `backend/server.js` | Challenge → verify → session → segment-key gating, plus an admin grant endpoint |

Not included yet (natural next steps, not built here): video encryption +
upload to IPFS/Arweave/Terabox, the HLS packaging pipeline, and a frontend
wallet-connect UI (wagmi/RainbowKit). Say the word and any of these can be
added next.

## Setup

### 1. Contracts

```bash
npm install
cp .env.example .env   # fill in SEPOLIA_RPC_URL + DEPLOYER_PRIVATE_KEY
npx hardhat compile
npx hardhat test
npm run deploy:sepolia
```

Get free Sepolia ETH for the deployer wallet from any public faucet (Alchemy,
Infura, Google Cloud) — you only need enough to cover your own `grantAccess`
calls, since viewers never transact.

Copy the deployed contract address into `.env` as `CONTRACT_ADDRESS`.

### 2. Gatekeeper backend

```bash
cd backend
npm install
node server.js
```

### 3. Try the flow end-to-end (e.g. with curl + a local ethers script)

```bash
# 1. Get a challenge
curl "http://localhost:3000/challenge?wallet=0xYourWallet&videoId=demo-video-1"

# 2. Sign the returned message with your wallet's private key (ethers.js:
#    await wallet.signMessage(message)), then:
curl -X POST http://localhost:3000/verify \
  -H "Content-Type: application/json" \
  -d '{"wallet":"0xYourWallet","videoId":"demo-video-1","message":"...","signature":"0x..."}'

# 3. Before this will succeed, an admin grant is required:
curl -X POST http://localhost:3000/admin/grant \
  -H "Content-Type: application/json" \
  -d '{"wallet":"0xYourWallet","videoId":"demo-video-1","expiresInSeconds":3600}'

# 4. Use the sessionToken from /verify to fetch a segment key:
curl "http://localhost:3000/segment-key?sessionToken=...&segment=segment_001.ts"
```

## Production hardening notes

- Swap the in-memory `nonceStore`/`sessionStore` (Maps) for Redis — required
  once you run more than one server instance.
- The `deriveSegmentKey` function is a placeholder; wire it to real
  per-video (or per-segment) key storage.
- Device fingerprint binding here is a plain string equality check — pair
  it with a real client-side fingerprint (canvas/UA hash) once the frontend
  is built.
- Screen recording isn't something any of this stops — if leak-traceability
  matters more than leak-prevention, consider per-wallet forensic
  watermarking on the video frames.
- Sepolia has an announced end-of-life around September 2026; a
  replacement testnet is expected to run in parallel during a transition
  period, so budget for a migration down the line.
