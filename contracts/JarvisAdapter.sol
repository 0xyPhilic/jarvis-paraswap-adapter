pragma solidity 0.8.9;

import "../interfaces/ISynthereumMultiLpLiquidityPool.sol";
import "../interfaces/IStandardERC20.sol";
import "../interfaces/IChainlinkPriceFeed.sol";
import "@aave/contracts/protocol/libraries/math/WadRayMath.sol";

contract JarvisAdapter {
    using WadRayMath for uint256;

    uint256 constant ONE_HUNDRED = 1 ether;

    function buyExactSyntheticTokens(
        address _collateralToken,
        address _synthereumPool,
        address _aggregator,
        uint256 _syntheticAmountToBuy,
        uint256 _expiration,
        uint256 _feePercentage
    ) external {
        IChainlinkPriceFeed chainlinkPriceFeed = IChainlinkPriceFeed(
            _aggregator
        );
        uint256 adjustedPrice = uint256(chainlinkPriceFeed.latestAnswer()) *
            (10 ** (18 - chainlinkPriceFeed.decimals()));

        uint256 expectedCollateral = _syntheticAmountToBuy
            .wadMul(adjustedPrice)
            .wadDiv(ONE_HUNDRED - _feePercentage);

        uint256 finalCollateralToPay = _convertDecimalsDown(
            expectedCollateral,
            IStandardERC20(_collateralToken)
        );
        IStandardERC20(_collateralToken).transferFrom(
            msg.sender,
            address(this),
            finalCollateralToPay
        );
        ISynthereumMultiLpLiquidityPool.MintParams
            memory mintParams = ISynthereumMultiLpLiquidityPool.MintParams(
                _syntheticAmountToBuy,
                finalCollateralToPay,
                _expiration,
                msg.sender
            );
        IStandardERC20(_collateralToken).approve(
            _synthereumPool,
            finalCollateralToPay
        );
        ISynthereumMultiLpLiquidityPool(_synthereumPool).mint(mintParams);
    }

    function buyExactCollateral(
        address _syntheticToken,
        address _synthereumPool,
        address _aggregator,
        uint256 _collateralAmountToBuy,
        uint256 _expiration,
        uint256 _feePercentage
    ) external {
        IChainlinkPriceFeed chainlinkPriceFeed = IChainlinkPriceFeed(
            _aggregator
        );
        uint256 adjustedPrice = uint256(chainlinkPriceFeed.latestAnswer()) *
            (10 ** (18 - chainlinkPriceFeed.decimals()));

        IStandardERC20 _collateralToken = ISynthereumMultiLpLiquidityPool(
            _synthereumPool
        ).collateralToken();
        uint256 adjustedCollateral = _convertDecimalsUp(
            _collateralAmountToBuy,
            _collateralToken
        );
        uint256 expectedSyntheticTokens = adjustedCollateral
            .wadDiv(adjustedPrice)
            .wadDiv(ONE_HUNDRED - _feePercentage);

        IStandardERC20(_syntheticToken).transferFrom(
            msg.sender,
            address(this),
            expectedSyntheticTokens
        );
        ISynthereumMultiLpLiquidityPool.RedeemParams
            memory redeemParams = ISynthereumMultiLpLiquidityPool.RedeemParams(
                expectedSyntheticTokens,
                _collateralAmountToBuy,
                _expiration,
                msg.sender
            );
        IStandardERC20(_syntheticToken).approve(
            _synthereumPool,
            expectedSyntheticTokens
        );
        ISynthereumMultiLpLiquidityPool(_synthereumPool).redeem(redeemParams);
    }

    function _convertDecimalsUp(
        uint256 _expectedAmount,
        IStandardERC20 _token
    ) internal view returns (uint256 finalValue) {
        finalValue = _expectedAmount * (10 ** (18 - _token.decimals()));
    }

    function _convertDecimalsDown(
        uint256 _expectedAmount,
        IStandardERC20 _token
    ) internal view returns (uint256 finalValue) {
        finalValue = _expectedAmount / (10 ** (18 - _token.decimals()));
    }
}
