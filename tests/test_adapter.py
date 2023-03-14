from brownie import config, network, JarvisAdapter, Contract, interface, accounts, Wei
from scripts.helpful_scripts import get_account
import pytest
from scripts.deploy_adapter import deploy_adapter

# The below values can be set to test on different pools/synths/collaterals
# Note: Aggregator address can be obtained from Chainlink docs for the specific network --> https://docs.chain.link/data-feeds/price-feeds/addresses
collateralUsed = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174"  # USDC
syntheticTokenUsed = "0xBD1fe73e1f12bD2bc237De9b626F056f21f86427"  # jMXN
poolUsed = "0x25E9F976f5020F6BF2d417b231e5f414b7700E31"  # jMXN/USDC
aggregatorAddress = "0x171b16562EA3476F5C61d1b8dad031DbA0768545"  # MXN / USD Price Feed
userWithCollateral = "0x9c2bd617b77961ee2c5e3038dfb0c822cb75d82a"  # A user that has USDC on Polygon --> should be changed if another chain/collateral is used
userWithSyntheticTokens = "0x1F7F63b1F6B12aCBB7B6400d91AEe6a50A463f07"  #  A user that has jMXN on Polygon --> should be changed if another chain/collateral is used
exactSyntheticAmountToBuy = Wei(
    "100 ether"
)  # The amount of Synthetic Tokens you want to buy for testing buyExactSyntheticTokens()
exactCollateralAmountToBuy = Wei(
    "100 mwei"
)  # Pre-set amount of collateral to buy for USDC --> 100000000


@pytest.fixture(scope="session")
def collateral(interface):
    yield interface.IStandardERC20(collateralUsed)


@pytest.fixture(scope="session")
def pool(interface):
    yield interface.ISynthereumMultiLpLiquidityPool(poolUsed)


@pytest.fixture(scope="session")
def synthetic_token(interface):
    yield interface.IStandardERC20(syntheticTokenUsed)


def test_adapter(collateral, pool, synthetic_token):
    account = get_account()
    adapter = deploy_adapter()
    collateral.transfer(
        account, collateral.balanceOf(userWithCollateral), {"from": userWithCollateral}
    )
    assert collateral.balanceOf(account) > 0
    collateral.approve(adapter.address, Wei("10000000 ether"), {"from": account})
    assert collateral.allowance(account, adapter.address) > 0
    adapter.buyExactSyntheticTokens(
        collateral.address,
        pool.address,
        aggregatorAddress,
        exactSyntheticAmountToBuy,
        1777575140,
        pool.feePercentage(),
        {"from": account},
    )
    assert synthetic_token.balanceOf(account) >= exactSyntheticAmountToBuy
    synthetic_token.transfer(
        account,
        synthetic_token.balanceOf(userWithSyntheticTokens),
        {"from": userWithSyntheticTokens},
    )
    assert synthetic_token.balanceOf(account) > 0
    synthetic_token.approve(adapter.address, Wei("1000000 ether"), {"from": account})
    assert synthetic_token.allowance(account, adapter.address) > 0
    adapter.buyExactCollateral(
        synthetic_token.address,
        pool.address,
        aggregatorAddress,
        exactCollateralAmountToBuy,
        1777575140,
        pool.feePercentage(),
        {"from": account},
    )
    assert synthetic_token.balanceOf(account) >= exactCollateralAmountToBuy
