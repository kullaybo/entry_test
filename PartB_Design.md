# Part B: Design Document

**Section 1: SkillsMarketplace (Agricultural Marketplace)**

**Section 2: SecureLottery (DeFi & NFT Integration)**

---

## WHY I BUILT IT THIS WAY

### 1. Data Structure Choices
**Explain your design decisions for BOTH contracts:**
- When would you choose to use a `mapping` instead of an `array`?
- How did you structure your state variables in `SkillsMarketplace` vs `SecureLottery`?
- What trade-offs did you consider for storage efficiency?

[**SkillsMarketplace**:
Structs: Used a `Gig` struct to group related data (employer, worker, bounty, status) efficiently. This reduces the number of mappings needed and makes the code more readable.

Mappings: Used `mapping(uint256 => Gig)` for O(1) access to gigs by ID. Used `mapping(address => bool)` for worker registration to prevent duplicate sign-ups cheaply.

Trade-offs: I chose mappings over arrays for storing gigs to save gas on lookups, but this means we cannot easily "loop" through all gigs without an external indexer (The Graph) or a counter.

**SecureLottery:**
Arrays: Used `address[] players` because we need to iterate or pick a random index from the total list of entries.

Nested Mappings: Used `mapping(uint256 => mapping(address => bool))` to track unique players per lottery round. This allows us to enforce the "3 unique players" rule efficiently without iterating through the array every time someone enters.]

---

### 2. Security Measures
**What attacks did you protect against in BOTH implementations?**
- Reentrancy attacks? (Explain your implementation of the Checks-Effects-Interactions pattern)
- Access control vulnerabilities?
- Integer overflow/underflow?
- Front-running/Randomness manipulation (specifically for `SecureLottery`)?

[Reentrancy Protection: In `SkillsMarketplace.approveAndPay`, I strictly followed the Checks-Effects-Interactions pattern. I set `gig.isCompleted = true` and `gig.bounty = 0` (Effects) before transferring ETH (Interaction).

Access Control: Used `onlyOwner` modifiers for administrative functions like `selectWinner` and `pause`.
Randomness: For the lottery, I utilized `block.prevrandao` (EIP-4399) combined with `block.timestamp` and `players.length`. While not perfect (Chainlink VRF is better), this is the standard for native randomness in modern Solidity (0.8.18+).

Circuit Breaker: Implemented `pause()` and `unpause()` with the `whenNotPaused` modifier to stop the contract in case of a bug or attack.]

---

### 3. Trade-offs & Future Improvements
**What would you change with more time?**
- Gas optimization opportunities?
- Additional features (e.g., dispute resolution, multiple prize tiers)?
- Better error handling?

[Pull over Push: Currently, `approveAndPay` pushes ETH to the worker. A better pattern (Pull) would be to update a balance mapping and let the worker `withdraw()`. This prevents the employer from getting stuck if the worker's address reverts.

Chainlink VRF: The current randomness can technically be influenced by validators. In a production environment, I would use Chainlink VRF for provably fair randomness.

Dispute Resolution: Currently, only the employer can approve work. I would add an arbitrator role to resolve disputes if an employer refuses to pay.e]

---

## REAL-WORLD DEPLOYMENT CONCERNS

### 1. Gas Costs
**Analyze the viability of your contracts for real-world use:**
- Estimated gas for key functions (e.g., `postGig`, `selectWinner`).
- Is this viable for users in constrained environments (e.g., high gas fees)?
- Any specific optimization strategies you implemented?

[Lottery Limits: The `players` array could hit the block gas limit if thousands of users enter. To scale, I would limit the max number of players per round or implement a Merkle Tree claim system.

Marketplace: The mapping-based approach scales well indefinitely, as there is no loop iterating over all gigs.]

---

### 2. Scalability
**What happens with 10,000+ entries/gigs?**
- Performance considerations for loops or large arrays.
- Storage cost implications.
- Potential bottlenecks in `selectWinner` or `applyForGig`.

[Write your response here]

---

### User Experience

**How would you make this usable for non-crypto users?**
- Onboarding process?
- MetaMask alternatives?
- Mobile accessibility?

[Write about your UX(user experience) considerations]

---

## MY LEARNING APPROACH

### Resources I Used

**Show self-directed learning:**
- Documentation consulted
- Tutorials followed
- Community resources

[List 3-5 resources you used]

---

### Challenges Faced

**Problem-solving evidence:**
- Biggest technical challenge
- How you solved it
- What you learned

[Write down your challenges]

---

### What I'd Learn Next

**Growth mindset indicator:**
- Advanced Solidity patterns
- Testing frameworks
- Frontend integration

[Foundry: I want to learn Foundry for faster fuzz testing.
Chainlink Integration: Implementing real VRF and Automation.
Frontend: connecting these contracts to a Next.js frontend using Wagmi/Viem.]

---
