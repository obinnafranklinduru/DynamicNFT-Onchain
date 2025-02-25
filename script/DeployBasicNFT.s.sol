// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {BasicNFT} from "../src/BasicNFT.sol";

contract DeployBasicNFT is Script {
    function run() external returns (BasicNFT) {
        vm.startBroadcast();
        BasicNFT nft = new BasicNFT("BasicNFT", "BNFT");
        console.log("BasicNFT deployed at:", address(nft));
        vm.stopBroadcast();

        return nft;
    }
}
