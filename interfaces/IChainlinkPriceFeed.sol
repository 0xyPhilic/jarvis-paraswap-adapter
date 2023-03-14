// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";

interface IChainlinkPriceFeed is AggregatorV3Interface, AggregatorInterface {}
