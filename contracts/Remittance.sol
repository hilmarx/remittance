pragma solidity >=0.4.21 <0.6.0;

contract Remittance {
    // State variables
    
    // Struct storing individual remittances
    struct SingleRemittance {
        address sender;
        address receiver;
        bytes32 hash;
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
    

}

