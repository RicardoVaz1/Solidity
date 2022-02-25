pragma solidity 0.5.1;

contract Storage {
    //Exercise 7 - Buy Token
    mapping(address => int256) public balances;
    address payable wallet;
    
    constructor(address payable _wallet) public {
        wallet = _wallet;
    }
    
    //payable - in order to buyToken() function accept ether, we need to add "payable" modifier
    function buyToken() public payable {
        // buy a token
        balances[msg.sender] += 1;
        
        // send ether to the wallet
        wallet.transfer(msg.value);
    }
}   