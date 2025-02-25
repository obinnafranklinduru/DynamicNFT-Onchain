// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {BasicNFT} from "../src/BasicNFT.sol";
import {DeployBasicNFT} from "../script/DeployBasicNFT.s.sol";

contract BasicNFTTest is Test {
    DeployBasicNFT public deployer;
    BasicNFT public basicNFT;

    address public user = makeAddr("user");
    string public constant TOKENURI = "https://example.com/token.json";

    function setUp() public {
        deployer = new DeployBasicNFT();
        basicNFT = deployer.run();
    }

    function testMinting() public {
        vm.prank(user);
        basicNFT.mint(user, TOKENURI);

        assertEq(basicNFT.ownerOf(1), user);
        assertEq(basicNFT.tokenURI(1), TOKENURI);
    }

    function testMintingMultiple() public {
        vm.prank(user);
        basicNFT.mint(user, TOKENURI);
        basicNFT.mint(user, TOKENURI);

        assertEq(basicNFT.ownerOf(1), user);
        assertEq(basicNFT.ownerOf(2), user);
        assertEq(basicNFT.tokenURI(1), TOKENURI);
        assertEq(basicNFT.tokenURI(2), TOKENURI);
    }
}
