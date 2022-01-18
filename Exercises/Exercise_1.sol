pragma solidity 0.5.1;

contract Storage {
    //Exercise 1
    string public value = "myValue";
    //string public constant value = "myValue";
    bool public myBool = true;
    int public myInt = -1; //can be negative
    uint public myUint = 1; //can't be negative
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
    }
}