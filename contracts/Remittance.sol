pragma solidity >=0.4.21 <0.6.0;

import './SafeMath.sol';
import './Stoppable.sol';

/// @title Remittance - Transfer ETH via a local exchange
/// @author hilmarx
/// @notice You can use this contract to transfer ETH to a recipient that does not hold an ethereum address through a trusted third party, without giving that party the ability to withdraw the funds without the actual recipients permission
/// @dev This is a test version, please don't use in production

contract Remittance is Stoppable {
    
    using SafeMath for uint256;
    
    // State variables
    
    // Struct storing individual remittances
    struct SingleRemittance {
        address sender;
        address receiver;
        bytes32 pwHash;
        uint amount;
        uint deadline;
    }

    // Mapping to store all Single Remittances
    mapping(uint => SingleRemittance) public remittances;

    // Index for searching through remittances mapping. Only contract can modify it
    uint internal index;

    // Event Listeners

    // Event when Remittance gets created
    event LogRemittanceCreation(address indexed sender, address indexed receiver, uint indexed remittanceIndex, uint amount);

    // Event when Remittance gets withdrawn by receiver
    event LogRemittancewithdrawal(address indexed sender, address indexed receiver, uint indexed remittanceIndex, uint amount);

    // Event when Remittance gets cancelled and withdrawn by sender
    event LogRemittanceCanceledAndWithdrawn(address indexed sender, address indexed receiver, uint indexed remittanceIndex, uint amount);

    constructor() public {
        index = 0;
    }

    ///@dev create Remittance with receiver address and pwHash
    function createRemittance(address receiver, bytes32 pwHash)
        public
        payable
        onlyIfRunning
        returns (uint _index) 
    {
        // Check if msg.value is greater than 0
        require( msg.value > 0, "You cannot send 0 ether" );

        // Check if receiver address is not null address
        require( receiver != address(0), "Address must not be null address" );

        // Set deadline to now + 48 hours

        uint newDeadline = now.add(172800);

        // Create new Single Remittance and store in the remittance mapping
        remittances[index] = SingleRemittance(msg.sender, receiver, pwHash, msg.value, newDeadline);
       
        // Emit event that Remittance was created
        emit LogRemittanceCreation(msg.sender, receiver, index, msg.value);
        
        // increase index counter
        index = index.add(1);

        return index;
    }

    ///@dev enables receiver of remittance to withdraw their funds from the remittance
    function withdrawRemittance(uint _index, string memory pw1, string memory pw2) 
    public 
    onlyIfRunning
    returns (bool success)
    {
        // Get the respective Single Remittances using the index
        SingleRemittance storage selectedRemittance = remittances[_index];

        // Check if msg.sender is receiver
        require(selectedRemittance.receiver == msg.sender, "You're not the receiver of this remittance");

        // Check if amount in Remittance is greater than 0
        require(selectedRemittance.amount > 0, "check if amount of remittance is greater than 0");

        // Check if passwords were inputted correctly
        require(selectedRemittance.pwHash == keccak256(abi.encodePacked(pw1, pw2)) ||selectedRemittance.pwHash == keccak256(abi.encodePacked(pw2, pw1)), "wrong password");

        // Store withdrawal amount to be used after Remittance gets deleted
        uint withdrawAmount = selectedRemittance.amount;

        // Delete selectedRemittance from storage mapping
        delete remittances[_index];

        // emit withdrawal event
        emit LogRemittancewithdrawal(selectedRemittance.sender, msg.sender, index, withdrawAmount);

        // Transfer funds to receiver
        msg.sender.transfer(withdrawAmount);

        return true;
    }

    function senderWithdrawRemittance(uint _index) 
        public 
        onlyIfRunning
        returns (bool success)
    {
        // Get the respective Single Remittances using the index
        SingleRemittance storage selectedRemittance = remittances[_index];

        // Make sure sender is msg.sender
        require(selectedRemittance.sender == msg.sender, "You are not the sender of the remittance");

        // Make sure deadline unix timestamp is smaller than the current time
        require(selectedRemittance.deadline < now, "You cannot withdraw your funds yet");

        // Store withdrawal amount to be used after Remittance gets deleted
        uint withdrawAmount = selectedRemittance.amount;

        // Delete selectedRemittance from storage mapping
        delete remittances[_index];

        // emit withdrawal event
        emit LogRemittanceCanceledAndWithdrawn(selectedRemittance.sender, msg.sender, index, withdrawAmount);

        // Transfer funds to receiver
        msg.sender.transfer(withdrawAmount);

        return true;

    }
}

