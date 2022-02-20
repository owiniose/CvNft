 // SPDX-License-Identifier: MIT
  pragma solidity ^0.8.4;
  import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
  import "@openzeppelin/contracts/access/Ownable.sol";
  import "./IWhitelist.sol";
  import "@openzeppelin/contracts/utils/Strings.sol";
  
    contract OwiniCvNft is ERC721Enumerable, Ownable {

    string _baseTokenURI;

      //  _price is the price of one Owini CV NFT
      uint256 public _price = 0.01 ether;

      // _paused is used to pause the contract in case of an emergency
      bool public _paused;

      // max number of Owini Cv
      uint256 public maxTokenIds = 200;

      // total number of tokenIds minted
      uint256 public tokenIds;

      // Whitelist contract instance
      IWhitelist whitelist;

      modifier onlyWhenNotPaused {
          require(!_paused, "Contract currently paused");
          _;
 }

 constructor (string memory baseURI, address whitelistContract) ERC721("Owini CV", "CV") {
          _baseTokenURI = baseURI;
          whitelist = IWhitelist(whitelistContract);
      }
      

       function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
            require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

            string memory baseURI = _baseURI();
            // Here it checks if the length of the baseURI is greater than 0, if it is return the baseURI and attach
            // the tokenId and `.json` to it so that it knows the location of the metadata json file for a given
            // tokenId stored on IPFS
            // If baseURI is empty return an empty string
            return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenIds), ".json")) : "";
        }

       function mint() public payable onlyWhenNotPaused {
       require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
          require(tokenIds < maxTokenIds, "Exceeded maximum Cypto Devs supply");
          require(msg.value >= _price, "Ether sent is not correct");
          tokenIds += 1;
          //_safeMint is a safer version of the _mint function as it ensures that
          // if the address being minted to is a contract, then it knows how to deal with ERC721 tokens
          // If the address being minted to is not a contract, it works the same way as _mint
          _safeMint(msg.sender, tokenIds);
      }

      /**
      * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
      * returned an empty string for the baseURI
      */
      function _baseURI() internal view virtual override returns (string memory) {
           return _baseTokenURI;
       }

      /**
      * @dev setPaused makes the contract paused or unpaused
       */
      function setPaused(bool val) public onlyOwner {
          _paused = val;
      }

      /**
      * @dev withdraw sends all the ether in the contract
      * to the owner of the contract
       */
      function withdraw() public onlyOwner  {
          address _owner = owner();
          uint256 amount = address(this).balance;
          (bool sent, ) =  _owner.call{value: amount}("");
          require(sent, "Failed to send Ether");
      }

       // Function to receive Ether. msg.data must be empty
      receive() external payable {}

      // Fallback function is called when msg.data is not empty
      fallback() external payable {}
  }
