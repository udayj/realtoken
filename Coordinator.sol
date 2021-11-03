// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "./RealEstToken.sol";
import "./RealEstNFT.sol";


contract Coordinator {
    
    RealEstToken _rToken;
    RealEstNFT _rNFT;
    uint256 pricePerToken;
    constructor(address tokenContractAddress, address nftContractAddress,uint _price) {
        _rToken=RealEstToken(tokenContractAddress);
        _rNFT=RealEstNFT(nftContractAddress);
        pricePerToken=_price;
    }
    
    function buyToken(uint256 _numTokens) public payable {
        require(msg.value > _numTokens*pricePerToken,"Need more funds");
        _rToken.mint(msg.sender,_numTokens*pricePerToken);
        
    }
    
    function buyUnit(uint256 _project, uint256 _unitType) public {
        
        uint256 numTokensRequired= _project*_unitType*500;
        _rToken.transferFrom(msg.sender,address(this),numTokensRequired);
        _rNFT.mintNFT(_project,_unitType,msg.sender);
    }
    
    
    
}
