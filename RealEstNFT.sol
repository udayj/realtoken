// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstNFT is ERC721URIStorage, Ownable {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    constructor() ERC721("RealEstNFT", "RENFT") {}
    
    function createProjectUnits() public onlyOwner {
        
    }

    function mintNFT(uint256 _project, uint256 _unitType, address buyer) public onlyOwner {
        
        require(buyer != address(0));
        
        uint256 newItemId = _tokenIds.current();
        
        
        _safeMint(buyer, newItemId);
        
        if(_project==1 && _unitType==1) {
        _setTokenURI(newItemId,"https://jsonkeeper.com/b/N3G0");
        }
        else {
             _setTokenURI(newItemId,"https://jsonkeeper.com/b/6YN1");
        }
        
        _tokenIds.increment();
        
    }
    // The following functions are overrides required by Solidity.
    
    
}
