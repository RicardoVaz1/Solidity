//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract Greeter {
    string private greeting;

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting: ", _greeting);
        greeting = _greeting;
    }

    //public --> means that this function can be read from outside of smart contract (Ex: From the Frontend - React Application)
    //view --> means that we are not modifying any states we're not writing anything to the blockchain, but we are reading from the blockchain
    //pure function --> in case if we were not reading from the blockchain and we just wanted to return a hard-coded value

    function greet() public view returns (string memory) {
        return greeting;
    }

    //When we use the setGreeting function we need to pay some type of gas for this transaction to be written
    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
}
