pragma solidity ^0.8.10;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract testToken is ERC20 {
  constructor() ERC20('maxToken', 'MFT') {
    _mint(msg.sender, 1000 * 10 ** 18); // Send 1000 tokens to the deployer of the token
  }
}