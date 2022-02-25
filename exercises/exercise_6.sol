pragma solidity 0.5.1;

contract Storage {
    //Exercise 6 - Time
    uint256 public peopleCount = 0;
    mapping(uint => Person) public people;
    
    //https://www.epochconverter.com/
    //https://www.epochconverter.com/clock
    uint256 openingTime = 1635180462; //epoch time its in seconds
    
    struct Person {
        uint _id;
        string _firstName;
        string _lastName;
    }
    
    modifier onlyWhileOpen() {
        //block.timestamp - The best way to "get now" in Solidty, is to get the current block timestamp
        
        //CurrentTime should be equal or higher than openingTime
        require(block.timestamp >= openingTime);
        _;
    }
    
    
    function addPerson(
        string memory _firstName, 
        string memory _lastName
    )
        public
        onlyWhileOpen
    {
        require(bytes(_firstName).length > 0 && bytes(_lastName).length > 0);
        
        incrementCount();
        people[peopleCount] = Person(peopleCount, _firstName, _lastName);
    }
    
    function incrementCount() internal {
        peopleCount += 1 ;
    }
    
    /*
    function get_owner() public view returns(address) {
        return owner;
    }
    
    function get_sender() public view returns(address) {
        return msg.sender;
    }
    */
}