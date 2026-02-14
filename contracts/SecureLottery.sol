// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SecureLottery
 * @dev An advanced lottery smart contract with security features
 * @notice PART 2 - Secure Lottery (MANDATORY)
 */
contract SecureLottery {
    
    address public owner;
    uint256 public lotteryId;
    uint256 public lotteryStartTime;
    bool public isPaused;
    
    // TODO: Define additional state variables
    // Consider:
    // - How will you track entries?
    // - How will you store player information?
    // - What data structure for managing the pot?

    address[] public players;
    mapping(uint256 => mapping(address => bool)) public hasEntered; 
    mapping(uint256 => uint256) public uniquePlayerCount;

    event PlayerEntered(address indexed player, uint256 amount, uint256 lotteryId);
    event WinnerSelected(address indexed winner, uint256 amountWon, uint256 lotteryId);
    event LotteryReset(uint256 newLotteryId);

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
        lotteryStartTime = block.timestamp;
        isPaused = false;
    }
    
    // TODO: Implement entry function
    // Requirements:
    // - Players pay minimum 0.01 ETH to enter
    // - Track each entry (not just unique addresses)
    // - Allow multiple entries per player
    // - Emit event with player address and entry count
    function enter() public payable whenNotPaused {
        require(msg.value >= 0.01 ether, "Minimum entry is 0.01 ETH");
        
        players.push(msg.sender);
        
        if (!hasEntered[lotteryId][msg.sender]) {
            hasEntered[lotteryId][msg.sender] = true;
            uniquePlayerCount[lotteryId]++;
        }
        
        emit PlayerEntered(msg.sender, msg.value, lotteryId);
    }
    
    // TODO: Implement winner selection function
    // Requirements:
    // - Only owner can trigger
    // - Select winner from TOTAL entries (not unique players)
    // - Winner gets 90% of pot, owner gets 10% fee
    // - Use a secure random mechanism (better than block.timestamp)
    // - Require at least 3 unique players
    // - Require lottery has been active for 24 hours
    function selectWinner() public onlyOwner {
        require(block.timestamp >= lotteryStartTime + 24 hours, "Lottery must run for 24 hours");
        require(uniquePlayerCount[lotteryId] >= 3, "Need at least 3 unique players");
        require(players.length > 0, "No players in lottery");
        require(address(this).balance > 0, "No funds to distribute");

        // Secure Randomness using block properties + array length
        uint256 randomness = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            players.length
        )));
        
        uint256 winnerIndex = randomness % players.length;
        address winner = players[winnerIndex];
        
        uint256 pot = address(this).balance;
        uint256 ownerFee = pot * 10 / 100; // 10%
        uint256 winnerPrize = pot - ownerFee; // 90%
        
        // Effects
        delete players; 
        lotteryId++;
        lotteryStartTime = block.timestamp;
        
        // Interactions
        (bool successOwner, ) = payable(owner).call{value: ownerFee}("");
        require(successOwner, "Owner transfer failed");
        
        (bool successWinner, ) = payable(winner).call{value: winnerPrize}("");
        require(successWinner, "Winner transfer failed");
        
        emit WinnerSelected(winner, winnerPrize, lotteryId - 1);
        emit LotteryReset(lotteryId);
    }
    
    // TODO: Implement circuit breaker (pause/unpause)
    // Requirements:
    // - Owner can pause lottery in emergency
    // - Owner can unpause lottery
    // - When paused, no entries allowed
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }
    
    function pause() public onlyOwner {
        isPaused = true;
    }
    
    function unpause() public onlyOwner {
        isPaused = false;
    }
    
    // TODO: Implement reentrancy protection
    // CRITICAL: Prevent reentrancy attacks when sending ETH
    // Use checks-effects-interactions pattern
    
    // TODO: Helper/View functions
    // - Get current pot balance
    // - Get player entry count
    // - Check if lottery is active
    // - Get unique player count
    function getPotBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPlayerCount() public view returns (uint256) {
        return players.length;
    }
    
    // BONUS: Add multiple prize tiers (1st, 2nd, 3rd place)
    // BONUS: Add refund mechanism if minimum players not reached
}