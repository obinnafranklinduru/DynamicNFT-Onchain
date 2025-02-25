// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {Script, console} from "forge-std/Script.sol";
import {BasicNFT} from "../src/BasicNFT.sol";
import {DeployBasicNFT} from "./DeployBasicNFT.s.sol";

contract MintBasicNFTInteraction is Script {
    BasicNFT public basicNFT;
    address public recipient = address(0x123);
    string public tokenURI =
        "https://ipfs.io/ipfs/Qmd3EEjNQRViwQtBUHYP6rF6bUJ8Ad1PpuGPfG16CDZq1U?filename=basic_one.json";

    function run() external {
        // address NFT_CONTRACT = DevOpsTools.get_most_recent_deployment("BasicNFT", block.chainid);
        // basicNFT = BasicNFT(NFT_CONTRACT);

        DeployBasicNFT deployer = new DeployBasicNFT();
        basicNFT = deployer.run();

        basicNFT.mint(recipient, tokenURI);

        console.log("Minted token for:", recipient);
        console.log("Token URI:", tokenURI);
    }
}
