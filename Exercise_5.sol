pragma solidity 0.5.1;

//import "@nomiclabs/buidler/console.sol";

contract Storage {
    //Exercise 5 - Permissions/Modifier
    uint256 public peopleCount = 0;
    mapping(uint => Person) public people;
    
    address owner;
    
    struct Person {
        uint _id;
        string _firstName;
        string _lastName;
    }
    
    constructor() public {
        owner = msg.sender;
        
        //console.log("Owner: ", owner);
        //console.log("Sender: ", sender);
    }
    
    modifier onlyOwner() {
        //msg - global keyword that stands fot the function metadata that's passed in
        //msg.sender - its the account/address who called the function
        
        require(msg.sender == owner); //if true continue, if false throw an error
        _;
    }
    
    
    function addPerson(
        string memory _firstName, 
        string memory _lastName
    )
        public
        onlyOwner
    {
        require(bytes(_firstName).length > 0 && bytes(_lastName).length > 0);
        
        incrementCount();
        people[peopleCount] = Person(peopleCount, _firstName, _lastName);
        
        //console.log("Owner: ", owner);
        //console.log("Sender: ", sender);
    }
    
    function incrementCount() internal {
        peopleCount += 1 ;
    }
    
    
    function get_owner() public view returns(address) {
        return owner;
    }
    
    function get_sender() public view returns(address) {
        return msg.sender;
    }
    
    /* 
    function get_owner2() public view returns(string memory) {
        string public owner2 = "Owner: " + abi.encodePacked(owner);
        return owner2;
    }
    
    function get_sender2() public view returns(string memory) {
        string public sender2 = "Sender: " + abi.encodePacked(msg.sender);
        return sender2;
    }
    */
}