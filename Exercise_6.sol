pragma solidity 0.5.1;

contract Storage {
    //Exercise 6 - Time
    uint256 public peopleCount = 0;
    mapping(uint => Person) public people;
    
    //https://www.epochconverter.com/
    uint256 openingTime = 1634748140; //epoch time is in seconds
    
    struct Person {
        uint _id;
        string _firstName;
        string _lastName;
    }
    
    modifier onlyWhileOpen() {
        //CurrentTime should be equal or higher than openingTime
        
        require(block.timestamp >= openingTime); //block.timestamp - get the value of epoch time
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