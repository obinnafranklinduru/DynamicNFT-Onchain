//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {OnchainCatNFT} from "../src/OnchainCatNFT.sol";

contract DeployOnchainCatNFT is Script {
    function run() external returns (OnchainCatNFT) {
        vm.startBroadcast();
        OnchainCatNFT onchainCatNFT = new OnchainCatNFT();
        console.log("Address OnchainCatNFT", address(onchainCatNFT));
        vm.stopBroadcast();

        return onchainCatNFT;
    }
}
