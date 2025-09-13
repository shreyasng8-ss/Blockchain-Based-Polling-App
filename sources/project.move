module MyModule::Polling {
    use aptos_framework::signer;
    use std::vector;
    use std::string::{String, utf8};

    /// Struct representing a poll with voting options
    struct Poll has store, key {
        question: String,           // The poll question
        options: vector<String>,    // List of voting options
        votes: vector<u64>,         // Vote count for each option
        voters: vector<address>,    // List of addresses that have voted
        is_active: bool,           // Whether the poll is still active
    }

    /// Error codes
    const E_POLL_NOT_FOUND: u64 = 1;
    const E_ALREADY_VOTED: u64 = 2;
    const E_INVALID_OPTION: u64 = 3;
    const E_POLL_INACTIVE: u64 = 4;

    /// Function to create a new poll with question and options
    public fun create_poll(
        creator: &signer, 
        question: vector<u8>, 
        option1: vector<u8>,
        option2: vector<u8>
    ) {
        let options = vector::empty<String>();
        vector::push_back(&mut options, utf8(option1));
        vector::push_back(&mut options, utf8(option2));
        
        let votes = vector::empty<u64>();
        vector::push_back(&mut votes, 0);
        vector::push_back(&mut votes, 0);
        
        let poll = Poll {
            question: utf8(question),
            options,
            votes,
            voters: vector::empty<address>(),
            is_active: true,
        };
        
        move_to(creator, poll);
    }

    /// Function for users to vote on a poll
    public fun vote(voter: &signer, poll_owner: address, option_index: u64) acquires Poll {
        let poll = borrow_global_mut<Poll>(poll_owner);
        let voter_addr = signer::address_of(voter);
        
        // Check if poll is active
        assert!(poll.is_active, E_POLL_INACTIVE);
        
        // Check if option index is valid
        assert!(option_index < vector::length(&poll.options), E_INVALID_OPTION);
        
        // Check if voter has already voted
        assert!(!vector::contains(&poll.voters, &voter_addr), E_ALREADY_VOTED);
        
        // Record the vote
        let current_votes = vector::borrow_mut(&mut poll.votes, option_index);
        *current_votes = *current_votes + 1;
        
        // Add voter to the list
        vector::push_back(&mut poll.voters, voter_addr);
    }
}