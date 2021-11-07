// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "./RealEstToken.sol";
import "./RealEstNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';



contract Coordinator is Ownable {
    
    RealEstToken _rToken;
    RealEstNFT _rNFT;
    uint256 pricePerToken;
    address public wEthToken =0xc778417E063141139Fce010982780140Aa0cD5Ab; //rinkeby weth address
    address public poolAddress;
    IUniswapV3Pool public pool;
    IUniswapV3Factory public factory;
   
    
    
    constructor(address tokenContractAddress, address nftContractAddress,uint _price) {
        _rToken=RealEstToken(tokenContractAddress);
        _rNFT=RealEstNFT(nftContractAddress);
        pricePerToken=_price;
        factory=IUniswapV3Factory(address(0x1F98431c8aD98523631AE4a59f267346ea31F984));
        
    }
    
    function setRTokenAddress(address tokenContractAddress) public  {
        _rToken=RealEstToken(tokenContractAddress);
    }
    
    function setRNFTAddress(address nftContractAddress) public {
        _rNFT=RealEstNFT(nftContractAddress);
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
    function setPoolAddress(address pa) public {
        poolAddress=pa;
        pool=IUniswapV3Pool(poolAddress);
    }
    
    function initializePool(uint160 sqrtPrice) public {
       
        pool.initialize(sqrtPrice);
    }
    
    function initializePool2(uint160 sqrtPrice) public returns (bool){
        (bool success, ) = (address(pool)).delegatecall(abi.encodeWithSignature("initialize(uint160)",sqrtPrice));
        return success;
    }
    function getToken0() public view returns (address) {
        return pool.token0();
    }
    
    function getToken1() public view returns(address) {
        return pool.token1();
    }
    
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
        return getSqrtRatioAtTick(meanTick);
        
    }
    
    
    function addLiquidity(uint128 amount) public returns (uint256,uint256) {
        (,int24 currentTick,,,,,) = pool.slot0();
        int24 tickSpacing = pool.tickSpacing();
        (uint256 amount0, uint256 amount1) = pool.mint(
            msg.sender,
            currentTick,
            currentTick + tickSpacing,
            amount,
            "0x"
            );
        return (amount0, amount1);
        
    }
    
    function getSlot0() public view returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        ) {
            return pool.slot0();
        }
    
    //the following function is directly from @uniswap/v3-core - TickMath.sol library
    //the library itself wasnt integrating due to higher version of compiler being used in this project
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
          
    int24 MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
    int24 MAX_TICK = -MIN_TICK;

   
    
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(int256(MAX_TICK)), 'T');

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    
    }
    fallback() external payable {}

    receive() external payable{}
    
}
