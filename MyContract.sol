pragma solidity 0.5.1;

contract Storage {
    //Exercicio 1
    /* string public value = "myValue";
    //string public constant value = "myValue";
    bool public myBool = true;
    int public myInt = -1; //pode ser negativo
    uint public myUint = 1; //nao pode ser negativo
    uint8 public myUint8 = 8;
    uint256 public myUint256 = 99999;
    
    
    constructor() public {
        value = "myValue";
    }
    
    function get() public view returns(string memory) {
        return value;
    }
    
    function set(string memory _value) public {
        value = _value;
    } */
    
    
    //Exercicio 2
    /* enum State {Waiting, Ready, Active}
    State public state;
    
    constructor() public {
        state = State.Waiting;
    }
    
    function activate() public{
        state = State.Active;
    }
    
    function isActive() public view returns(bool) {
        return state == State.Active;
    } */
    
    
    //Exercicio 3 - Array
    /* Person[] public people;
    
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
    } */
    
    
    //Exercicio 4 - Mapping
    /* uint256 public peopleCount = 0;
    mapping(uint => Person) public people;
    
    struct Person {
        uint _id;
        string _firstName;
        string _lastName;
    }
    
    function addPerson(string memory _firstName, string memory _lastName) public {
        require(bytes(_firstName).length > 0);
        require(bytes(_lastName).length > 0);
        
        peopleCount += 1;
        people[peopleCount] = Person(peopleCount, _firstName, _lastName);
    } */
    
    
    //Exercicio 5
    uint256 public peopleCount = 0;
}