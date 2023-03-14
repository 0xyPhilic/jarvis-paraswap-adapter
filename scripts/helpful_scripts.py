from brownie import accounts, network, config

LOCAL_BLOCKCHAIN_ENVIRONMENT = ["development"]
FORKED_LOCAL_BLOCKCHAIN = ["polygon-mainnet-fork"]


def get_account(index=None, id=None):
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENT
        or network.show_active() in FORKED_LOCAL_BLOCKCHAIN
    ):
        return accounts[0]

    return accounts.add(config["wallets"]["from_key"])
