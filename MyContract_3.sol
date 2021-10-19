pragma solidity 0.5.1;

contract Storage {
    //Exercicio 3 - Array 
    Person[] public people;
    
    uint256 public peopleCount;
    
    struct Person {
        string _firstName;
        string _lastName;
    }
    
    function addPerson(string memory _firstName, string memory _lastName) public {
        require(bytes(_firstName).length > 0); //tem que estar preenchido
        require(bytes(_lastName).length > 0); //tem que estar preenchido
        
        people.push(Person(_firstName, _lastName));
        peopleCount += 1;
    }
}