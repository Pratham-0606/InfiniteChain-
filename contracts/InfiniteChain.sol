// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title InfiniteChain
 * @dev A decentralized contract that manages user registrations and token-based rewards.
 */
contract Project {
    address public owner;

    struct User {
        bool isRegistered;
        uint256 balance;
    }

    mapping(address => User) private users;

    event UserRegistered(address indexed user);
    event TokensMinted(address indexed user, uint256 amount);
    event TokensTransferred(address indexed from, address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Register a new user in InfiniteChain
    function registerUser() external {
        require(!users[msg.sender].isRegistered, "Already registered");
        users[msg.sender].isRegistered = true;
        emit UserRegistered(msg.sender);
    }

    /// @notice Mint tokens to a registered user (only owner)
    function mintTokens(address user, uint256 amount) external onlyOwner {
        require(users[user].isRegistered, "User not registered");
        users[user].balance += amount;
        emit TokensMinted(user, amount);
    }

    /// @notice Transfer tokens between users
    function transferTokens(address to, uint256 amount) external {
        require(users[msg.sender].balance >= amount, "Insufficient balance");
        require(users[to].isRegistered, "Recipient not registered");

        users[msg.sender].balance -= amount;
        users[to].balance += amount;

        emit TokensTransferred(msg.sender, to, amount);
    }

    /// @notice Get user balance
    function getBalance(address user) external view returns (uint256) {
        return users[user].balance;
    }
}
