pragma solidity ^0.8.10;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract maxNFT is ERC721 {
  address public artist;      // Address for the right owners
  address public txFeeToken; // Address for the processing Fees for the royalty
  uint public txFeeAmount;   // amount
  mapping(address => bool) public excludedList; // List stating the free transferer like the artist himself

  constructor(
    address _artist, 
    address _txFeeToken,
    uint _txFeeAmount
  ) ERC721('MaxNFT', 'MFT') { // ERC721('NFT name', 'NFT SYMBOL')
    artist = _artist;
    txFeeToken = _txFeeToken;
    txFeeAmount = _txFeeAmount;
    excludedList[_artist] = true; // The Artist should not pay fees to himself
    _mint(artist, 0);      // Mint one NFT
  }

// Update the excluded list
  function setExcluded(address excluded, bool status) external {
    require(msg.sender == artist, 'artist only'); //only the artist can call this function
    excludedList[excluded] = status;
  }

  function transferFrom(
    address from, 
    address to, 
    uint256 tokenId
  ) public override {   // We overwrite this object as it is a virtual in openzeppelin
     require(
       _isApprovedOrOwner(_msgSender(), tokenId), 
       'ERC721: transfer caller is not owner nor approved'
     );  // Make sure that the owner is valid
     if(excludedList[from] == false) {
      _payTxFee(from); // Pay the fee
     }
     _transfer(from, to, tokenId); // From openzeppelin/contracts/token/ERC20/IERC20
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
   ) public override {
     if(excludedList[from] == false) {
       _payTxFee(from);
     }
     safeTransferFrom(from, to, tokenId, ''); // to avoid locked tokens
   }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public override {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId), 
      'ERC721: transfer caller is not owner nor approved'
    );
    if(excludedList[from] == false) {
      _payTxFee(from);
    }
    _safeTransfer(from, to, tokenId, _data);
  }

  function _payTxFee(address from) internal {
    IERC20 token = IERC20(txFeeToken);     // Pointer to the creator of the interface IERC20
    token.transferFrom(from, artist, txFeeAmount); // fransfer the fee from the sender to the artist the fee
  }
}