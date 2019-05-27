pragma solidity >=0.4.21 <0.6.0;

contract Remittance {
    // State variables
    
    // Struct storing individual remittances
    struct SingleRemittance {
        address sender;
        address receiver;
        bytes32 pwHash;
        uint amount;
    }

    // Mapping to store all Single Remittances
    mapping(uint => SingleRemittance) public remittances;

    // Index for searching through remittances mapping. Only contract can modify it
    uint internal index;

    // Owner of the contract
    address public owner; 

    // Event Listeners

    event LogRemittanceCreation(address indexed sender, address indexed receiver, uint indexed remittanceIndex, uint amount);

    event LogRemittancewithdrawal(address indexed sender, address indexed receiver, uint indexed remittanceIndex, uint amount);

    constructor() public {
        owner = msg.sender;
        index = 0;
    }

    function createRemittance(address receiver, bytes32 pwHash)
        public
        payable
        returns (uint _index) 
    {
        // Check if msg.value is greater than 0
        require( msg.value > 0, "You cannot send 0 ether" );
        // Check if receiver address is not null address
        require( receiver != address(0), "Address must not be null address" );

        remittances[index] = SingleRemittance(msg.sender, receiver, pwHash, msg.value);
        emit LogRemittanceCreation(msg.sender, receiver, index, msg.value);
        index++;
        return index;
    }

    function withdrawRemittance(uint _index, string memory pw1, string memory pw2) 
    public 
    returns (bool success)
    {
        SingleRemittance storage selectedRemittance = remittances[_index];
        // Check if msg.sender is receiver
        require(selectedRemittance.receiver == msg.sender, "You're not the receiver of this remittance");
        // Check if amount in Remittance is greater than 0
        require(selectedRemittance.amount > 0, "check if amount of remittance is greater than 0");
        // Check if passwords were inputted correctly
        require(selectedRemittance.pwHash == keccak256(abi.encodePacked(pw1, pw2)) ||selectedRemittance.pwHash == keccak256(abi.encodePacked(pw2, pw1)), "wrong password");

        uint withdrawAmount = selectedRemittance.amount;
        // Delete selectedRemittance from storage mapping
        delete remittances[_index];

        // emit withdrawal event
        emit LogRemittancewithdrawal(selectedRemittance.sender, msg.sender, index, withdrawAmount);

        // Transfer funds to receiver
        msg.sender.transfer(withdrawAmount);
        return true;
    }
}

