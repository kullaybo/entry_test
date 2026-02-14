// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SkillsMarketplace
 * @dev A decentralised marketplace for skills and gigs
 * @notice PART 1 - Skills Marketplace (MANDATORY)
 */
contract SkillsMarketplace {
    
    // TODO: Define your state variables here
    // Consider:
    // - How will you track workers and their skills?
    // - How will you store gig information?
    // - How will you manage payments?

    struct Gig {
        uint256 gigId;
        address employer;
        address worker;
        string description;
        string skillRequired;
        uint256 bounty;
        bool isOpen;
        bool workSubmitted;
        bool isCompleted;
    }

    uint256 public gigCounter;
    mapping(uint256 => Gig) public gigs;
    mapping(address => string) public workerSkills;
    mapping(address => bool) public isWorkerRegistered;

    event WorkerRegistered(address indexed worker, string skill);
    event GigPosted(uint256 indexed gigId, address indexed employer, uint256 bounty, string skillRequired);
    event GigApplied(uint256 indexed gigId, address indexed worker);
    event WorkSubmitted(uint256 indexed gigId, address indexed worker, string url);
    event GigPaid(uint256 indexed gigId, address indexed worker, uint256 amount);
    
    address public owner;

    constructor() {
        owner = msg.sender;
    }
    
    // TODO: Implement registerWorker function
    // Requirements:
    // - Workers should be able to register with their skill
    // - Prevent duplicate registrations
    // - Emit an event when a worker registers
    function registerWorker(string memory skill) public {
        require(bytes(skill).length > 0, "Skill cannot be empty");
        require(!isWorkerRegistered[msg.sender], "Already registered");
        
        workerSkills[msg.sender] = skill;
        isWorkerRegistered[msg.sender] = true;
        
        emit WorkerRegistered(msg.sender, skill);
    }
    
    // TODO: Implement postGig function
    // Requirements:
    // - Employers post gigs with bounty (msg.value)
    // - Store gig description and required skill
    // - Ensure ETH is sent with the transaction
    // - Emit an event when gig is posted
    function postGig(string memory description, string memory skillRequired) public payable {
        require(msg.value > 0, "Bounty must be greater than 0");
        require(bytes(description).length > 0, "Description required");
        require(bytes(skillRequired).length > 0, "Skill required");

        gigCounter++;
        gigs[gigCounter] = Gig({
            gigId: gigCounter,
            employer: msg.sender,
            worker: address(0),
            description: description,
            skillRequired: skillRequired,
            bounty: msg.value,
            isOpen: true,
            workSubmitted: false,
            isCompleted: false
        });

        emit GigPosted(gigCounter, msg.sender, msg.value, skillRequired);
    }
    
    // TODO: Implement applyForGig function
    // Requirements:
    // - Workers can apply for gigs
    // - Check if worker has the required skill
    // - Prevent duplicate applications
    // - Emit an event
    function applyForGig(uint256 gigId) public {
        Gig storage gig = gigs[gigId];
        require(gig.isOpen, "Gig is not open");
        require(isWorkerRegistered[msg.sender], "Worker not registered");
        require(keccak256(bytes(workerSkills[msg.sender])) == keccak256(bytes(gig.skillRequired)), "Skill mismatch");
        require(gig.worker == address(0), "Gig already has a worker");

        gig.worker = msg.sender;
        gig.isOpen = false;

        emit GigApplied(gigId, msg.sender);
    }
    
    // TODO: Implement submitWork function
    // Requirements:
    // - Workers submit completed work (with proof/URL)
    // - Validate that worker applied for this gig
    // - Update gig status
    // - Emit an event
    function submitWork(uint256 gigId, string memory submissionUrl) public {
        Gig storage gig = gigs[gigId];
        require(msg.sender == gig.worker, "Only assigned worker can submit");
        require(!gig.workSubmitted, "Work already submitted");
        require(bytes(submissionUrl).length > 0, "URL cannot be empty");

        gig.workSubmitted = true;
        
        emit WorkSubmitted(gigId, msg.sender, submissionUrl);
    }
    
    // TODO: Implement approveAndPay function
    // Requirements:
    // - Only employer who posted gig can approve
    // - Transfer payment to worker
    // - CRITICAL: Implement reentrancy protection
    // - Update gig status to completed
    // - Emit an event
    function approveAndPay(uint256 gigId, address worker) public {
        Gig storage gig = gigs[gigId];
        
        // Checks
        require(msg.sender == gig.employer, "Only employer can approve");
        require(gig.worker == worker, "Worker address mismatch");
        require(gig.workSubmitted, "Work not submitted yet");
        require(!gig.isCompleted, "Gig already completed");
        
        uint256 amount = gig.bounty;
        require(address(this).balance >= amount, "Insufficient contract balance");

        // Effects (Update state BEFORE transfer)
        gig.isCompleted = true;
        gig.bounty = 0; 

        // Interactions
        (bool success, ) = payable(worker).call{value: amount}("");
        require(success, "Transfer failed");

        emit GigPaid(gigId, worker, amount);
    }
    
    // BONUS: Implement dispute resolution
    // What happens if employer doesn't approve but work is done?
    // Consider implementing a timeout mechanism
    
    // Helper functions you might need:
    // - Function to get gig details
    // - Function to check worker registration
    // - Function to get all gigs
}