// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "./IStandardERC20.sol";

interface ISynthereumMultiLpLiquidityPool {
    struct MintParams {
        // Minimum amount of synthetic tokens that a user wants to mint using collateral (anti-slippage)
        uint256 minNumTokens;
        // Amount of collateral that a user wants to spend for minting
        uint256 collateralAmount;
        // Expiration time of the transaction
        uint256 expiration;
        // Address to which send synthetic tokens minted
        address recipient;
    }

    struct RedeemParams {
        // Amount of synthetic tokens that user wants to use for redeeming
        uint256 numTokens;
        // Minimium amount of collateral that user wants to redeem (anti-slippage)
        uint256 minCollateral;
        // Expiration time of the transaction
        uint256 expiration;
        // Address to which send collateral tokens redeemed
        address recipient;
    }

    /**
     * @notice Mint synthetic tokens using fixed amount of collateral
     * @notice This calculate the price using on chain price feed
     * @notice User must approve collateral transfer for the mint request to succeed
     * @param mintParams Input parameters for minting (see MintParams struct)
     * @return syntheticTokensMinted Amount of synthetic tokens minted by a user
     * @return feePaid Amount of collateral paid by the user as fee
     */
    function mint(
        MintParams calldata mintParams
    ) external returns (uint256 syntheticTokensMinted, uint256 feePaid);

    /**
     * @notice Redeem amount of collateral using fixed number of synthetic token
     * @notice This calculate the price using on chain price feed
     * @notice User must approve synthetic token transfer for the redeem request to succeed
     * @param redeemParams Input parameters for redeeming (see RedeemParams struct)
     * @return collateralRedeemed Amount of collateral redeem by user
     * @return feePaid Amount of collateral paid by user as fee
     */
    function redeem(
        RedeemParams calldata redeemParams
    ) external returns (uint256 collateralRedeemed, uint256 feePaid);

    /**
     * @notice Returns fee percentage of the pool
     * @return fee Fee percentage
     */
    function feePercentage() external view returns (uint256 fee);

    function collateralToken() external view returns (IStandardERC20);
}
