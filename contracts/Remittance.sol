pragma solidity >=0.4.21 <0.6.0;

contract Remittance {
    // State variables
    
    // Struct storing individual remittances
    struct SingleRemittance {
        address sender;
        address receiver;
        bytes pwHash;
        uint amount;
    }
    // Mapping to store all Single Remittances
    mapping(uint => SingleRemittance) public remittances;
    // Index for searching through remittances mapping. Only contract can modify it
    uint internal index;
    address public owner; 

    constructor() public {
        owner = msg.sender;
        index = 0;
    }

    function createRemittance(address receiver, bytes memory pwHash)
        public
        payable
        returns (bool success) 
    {
        // Check if msg.value is greater than 0
        require( msg.value > 0, "You cannot send 0 ether" );
        // Check if receiver address is not null address
        require( receiver != address(0), "Address must not be null address" );
        remittances[index] = SingleRemittance(msg.sender, receiver, pwHash, msg.value);
        return true;
    }

}

