// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Open Ballot — simple on-chain polling
/// @notice Anyone can create a poll with a question and a list of options.
///         Each wallet address may cast exactly one vote per poll. Results
///         are public and tamper-proof: no one, including the poll creator,
///         can alter votes once cast.
contract OpenBallot {
    struct Poll {
        address creator;
        string question;
        string[] options;
        uint256[] voteCounts;
        uint256 createdAt;
        bool exists;
        mapping(address => bool) hasVoted;
    }

    uint256 public pollCount;
    mapping(uint256 => Poll) private polls;

    event PollCreated(uint256 indexed pollId, address indexed creator, string question, uint256 optionCount);
    event VoteCast(uint256 indexed pollId, address indexed voter, uint256 optionIndex);

    /// @notice Create a new poll.
    /// @param question The question being asked.
    /// @param options 2 to 8 possible answers.
    function createPoll(string calldata question, string[] calldata options) external returns (uint256 pollId) {
        require(options.length >= 2 && options.length <= 8, "Need 2-8 options");
        require(bytes(question).length > 0, "Question required");

        pollId = pollCount;
        Poll storage p = polls[pollId];
        p.creator = msg.sender;
        p.question = question;
        p.createdAt = block.timestamp;
        p.exists = true;

        // Copy calldata array into storage manually — direct assignment of a
        // nested dynamic array (string[]) from calldata to storage isn't
        // supported by Solidity's legacy code generator.
        for (uint256 i = 0; i < options.length; i++) {
            p.options.push(options[i]);
            p.voteCounts.push(0);
        }

        pollCount++;
        emit PollCreated(pollId, msg.sender, question, options.length);
    }

    /// @notice Cast a vote on an existing poll. One vote per address per poll.
    function vote(uint256 pollId, uint256 optionIndex) external {
        Poll storage p = polls[pollId];
        require(p.exists, "Poll does not exist");
        require(!p.hasVoted[msg.sender], "Already voted");
        require(optionIndex < p.options.length, "Invalid option");

        p.hasVoted[msg.sender] = true;
        p.voteCounts[optionIndex] += 1;

        emit VoteCast(pollId, msg.sender, optionIndex);
    }

    /// @notice Read a poll's question, options, and live vote counts.
    function getPoll(uint256 pollId)
        external
        view
        returns (
            address creator,
            string memory question,
            string[] memory options,
            uint256[] memory voteCounts,
            uint256 createdAt,
            bool exists
        )
    {
        Poll storage p = polls[pollId];
        return (p.creator, p.question, p.options, p.voteCounts, p.createdAt, p.exists);
    }

    /// @notice Check whether a given address has already voted on a poll.
    function hasVoted(uint256 pollId, address voter) external view returns (bool) {
        return polls[pollId].hasVoted[voter];
    }
}
