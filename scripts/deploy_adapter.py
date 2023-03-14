from scripts.helpful_scripts import get_account
from brownie import JarvisAdapter, config, network


def deploy_adapter():
    account = get_account()
    jarvis_adapter = JarvisAdapter.deploy({"from": account})
    print("Jarvis Adapter deployed!")
    return jarvis_adapter


def main():
    deploy_adapter()
