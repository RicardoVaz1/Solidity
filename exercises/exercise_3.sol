pragma solidity 0.5.1;

contract Storage {
    //Exercise 3 - Array
    Person[] public people;
    
    uint256 public peopleCount;
    
    struct Person {
        string _firstName;
        string _lastName;
    }
    
    function addPerson(string memory _firstName, string memory _lastName) public {
        require(bytes(_firstName).length > 0); //need to be filled
        require(bytes(_lastName).length > 0); //need to be filled
        
        people.push(Person(_firstName, _lastName));
        peopleCount += 1;
    }
}