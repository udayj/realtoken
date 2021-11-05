// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "./RealEstToken.sol";
import "./RealEstNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import "@uniswap/v3-core/contracts/libraries/TickMath.sol";


contract Coordinator is Ownable {
    
    RealEstToken _rToken;
    RealEstNFT _rNFT;
    uint256 pricePerToken;
    address public wEthToken =0xd0A1E359811322d97991E03f863a0C30C2cF029C;
    address public poolAddress;
    IUniswapV3Pool public pool;
    IUniswapV3Factory public factory;
   
    
    
    constructor(address tokenContractAddress, address nftContractAddress,uint _price) {
        _rToken=RealEstToken(tokenContractAddress);
        _rNFT=RealEstNFT(nftContractAddress);
        pricePerToken=_price;
        factory=IUniswapV3Factory(address(0x1F98431c8aD98523631AE4a59f267346ea31F984));
        
    }
    
    function buyToken(uint256 _numTokens) public payable {
        require(msg.value > _numTokens*pricePerToken,"Need more funds");
        _rToken.mint(msg.sender,_numTokens);
        
    }
    
    function buyUnit(uint256 _project, uint256 _unitType) public {
        
        uint256 numTokensRequired= _project*_unitType*500;
        _rToken.transferFrom(msg.sender,address(this),numTokensRequired);
        _rNFT.mintNFT(_project,_unitType,msg.sender);
    }
    
    function getPricePerToken() public view returns(uint) {
        return pricePerToken;
    }
    
    function createPool() public {
        poolAddress=address(factory.createPool(address(_rToken),wEthToken,10000));
        pool=IUniswapV3Pool(poolAddress);
        
    }
    
    function initializePool(uint160 sqrtPrice) public {
        //require(pool!=address(0));
        pool.initialize(sqrtPrice);
    }
    
    /*function getToken0() public returns (address) {
        return pool.token0;
    }
    
    function getToken1() public returns(address) {
        return address(pool.token1);
    }*/ 
    
    function getTwapTickInInterval(uint32 interval) public view returns(int24) {
        uint32[] memory secondsAlgos = new uint32[](2);
        secondsAlgos[0]=interval;
        secondsAlgos[1]=0;
        (int56[] memory tCumulatives,) = pool.observe(secondsAlgos);
        int24 meanTick=int24((tCumulatives[1]-tCumulatives[0])/int32(interval)); //recheck this
        return meanTick;
        
    }
    
    function getSqrtPriceInInterval(uint32 interval) public view returns(uint160) {
        
        int24 meanTick = getTwapTickInInterval(interval);
        return TickMath.getSqrtRatioAtTick(meanTick);
        
    }
    function getPriceInInterval(uint32 interval) public returns(int24) {
        
    }
    fallback() external payable {}

    receive() external payable{}
    
}
