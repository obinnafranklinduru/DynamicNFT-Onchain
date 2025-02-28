// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {OnchainCatNFT} from "../src/OnchainCatNFT.sol";
import {DeployOnchainCatNFT} from "../script/DeployOnchainCatNFT.s.sol";

contract OnchainCatNFTTest is Test {
    DeployOnchainCatNFT public deployer;
    OnchainCatNFT public onchainCatNFT;

    address public user = makeAddr("user");

    event CatMinted(address indexed recipient, uint256 tokenId, string furColor);
    event Withdrawn(address indexed owner, uint256 amount);

    function setUp() public {
        deployer = new DeployOnchainCatNFT();
        onchainCatNFT = deployer.run();
    }

    function testMintInsufficientFunds() public {
        vm.startPrank(user);
        vm.deal(user, 0.5 ether);
        vm.expectRevert(OnchainCatNFT.InsufficientFunds.selector);
        onchainCatNFT.mint{value: 0.5 ether}();
        vm.stopPrank();
    }

    function testMintSuccess() public {
        vm.startPrank(user);
        vm.deal(user, 2 ether);
        onchainCatNFT.mint{value: 1 ether}();
        assertEq(onchainCatNFT.ownerOf(1), user);
        vm.stopPrank();
    }

    function testMintEmitsEvent() public {
        vm.startPrank(user);
        vm.deal(user, 1 ether);
        vm.expectEmit(true, true, true, true);
        emit CatMinted(user, 1, "orange");
        onchainCatNFT.mint{value: 1 ether}();
        vm.stopPrank();
    }

    function testMintIncreasesBalance() public {
        uint256 initialBalance = address(onchainCatNFT).balance;
        vm.prank(user);
        vm.deal(user, 1 ether);
        onchainCatNFT.mint{value: 1 ether}();
        assertEq(address(onchainCatNFT).balance, initialBalance + 1 ether);
    }

    function testWithdrawNonOwnerReverts() public {
        vm.prank(user);
        vm.expectRevert();
        onchainCatNFT.withdraw();
    }

    function testWithdrawInsufficientFunds() public {
        vm.prank(onchainCatNFT.owner());
        vm.expectRevert(OnchainCatNFT.InsufficientFunds.selector);
        onchainCatNFT.withdraw();
    }

    function testWithdrawSuccess() public {
        vm.startPrank(user);
        vm.deal(user, 1 ether);
        onchainCatNFT.mint{value: 1 ether}();
        vm.stopPrank();

        uint256 contractBalance = address(onchainCatNFT).balance;
        uint256 ownerBalanceBefore = onchainCatNFT.owner().balance;

        vm.startPrank(onchainCatNFT.owner());
        vm.expectEmit(true, true, true, true);
        emit Withdrawn(onchainCatNFT.owner(), contractBalance);
        onchainCatNFT.withdraw();

        assertEq(address(onchainCatNFT).balance, 0);
        assertEq(onchainCatNFT.owner().balance, ownerBalanceBefore + contractBalance);
        vm.stopPrank();
    }

    function testTokenURIRevertsForNonExistentToken() public {
        vm.expectRevert();
        onchainCatNFT.tokenURI(9999);
    }

    function testTokenURI() public {
        vm.startPrank(user);
        vm.deal(user, 1 ether);
        onchainCatNFT.mint{value: 1 ether}();
        vm.stopPrank();

        string memory expectedURI =
            "data:application/json;base64,eyJuYW1lIjogIk9uY2hhaW4gQ2F0ICMxIiwgImRlc2NyaXB0aW9uIjogIkEgZnVsbHkgb24tY2hhaW4gZ2VuZXJhdGVkIGNhdCBORlQuIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIkZ1ciBDb2xvciIsICJ2YWx1ZSI6ICJvcmFuZ2UifV0sICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIzYVdSMGFEMGlNakF3SWlCb1pXbG5hSFE5SWpJd01DSWdkbWxsZDBKdmVEMGlNQ0F3SURJd01DQXlNREFpSUhodGJHNXpQU0pvZEhSd09pOHZkM2QzTG5jekxtOXlaeTh5TURBd0wzTjJaeUkrUEdWc2JHbHdjMlVnWTNnOUlqRXdNQ0lnWTNrOUlqRXpNQ0lnY25nOUlqVXdJaUJ5ZVQwaU5qQWlJR1pwYkd3OUltOXlZVzVuWlNJZ0x6NDhZMmx5WTJ4bElHTjRQU0l4TURBaUlHTjVQU0k0TUNJZ2NqMGlOREFpSUdacGJHdzlJbTl5WVc1blpTSWdMejQ4Y0c5c2VXZHZiaUJ3YjJsdWRITTlJamN3TERVd0lEZzFMREl3SURFd01DdzFNQ0lnWm1sc2JEMGliM0poYm1kbElpOCtQSEJ2YkhsbmIyNGdjRzlwYm5SelBTSXhNekFzTlRBZ01URTFMREl3SURFd01DdzFNQ0lnWm1sc2JEMGliM0poYm1kbElpOCtQR05wY21Oc1pTQmplRDBpT0RVaUlHTjVQU0kzTlNJZ2NqMGlOaUlnWm1sc2JEMGlkMmhwZEdVaUx6NDhZMmx5WTJ4bElHTjRQU0l4TVRVaUlHTjVQU0kzTlNJZ2NqMGlOaUlnWm1sc2JEMGlkMmhwZEdVaUx6NDhZMmx5WTJ4bElHTjRQU0k0TlNJZ1kzazlJamMxSWlCeVBTSXpJaUJtYVd4c1BTSmliR0ZqYXlJdlBqeGphWEpqYkdVZ1kzZzlJakV4TlNJZ1kzazlJamMxSWlCeVBTSXpJaUJtYVd4c1BTSmliR0ZqYXlJdlBqeHdiMng1WjI5dUlIQnZhVzUwY3owaU9UVXNPRFVnTVRBMUxEZzFJREV3TUN3NU5TSWdabWxzYkQwaWNHbHVheUl2UGp4d1lYUm9JR1E5SWsweE1EQWdPVFVnVVRrd0lERXhNQ0E0TUNBeE1EQWlJSE4wY205clpUMGlZbXhoWTJzaUlHWnBiR3c5SW5SeVlXNXpjR0Z5Wlc1MElpOCtQSEJoZEdnZ1pEMGlUVEV3TUNBNU5TQlJNVEV3SURFeE1DQXhNakFnTVRBd0lpQnpkSEp2YTJVOUltSnNZV05ySWlCbWFXeHNQU0owY21GdWMzQmhjbVZ1ZENJdlBqeHNhVzVsSUhneFBTSTNNQ0lnZVRFOUlqa3dJaUI0TWowaU5EQWlJSGt5UFNJNE1DSWdjM1J5YjJ0bFBTSmliR0ZqYXlJdlBqeHNhVzVsSUhneFBTSTNNQ0lnZVRFOUlqRXdNQ0lnZURJOUlqUXdJaUI1TWowaU1UQXdJaUJ6ZEhKdmEyVTlJbUpzWVdOcklpOCtQR3hwYm1VZ2VERTlJamN3SWlCNU1UMGlNVEV3SWlCNE1qMGlOREFpSUhreVBTSXhNakFpSUhOMGNtOXJaVDBpWW14aFkyc2lMejQ4YkdsdVpTQjRNVDBpTVRNd0lpQjVNVDBpT1RBaUlIZ3lQU0l4TmpBaUlIa3lQU0k0TUNJZ2MzUnliMnRsUFNKaWJHRmpheUl2UGp4c2FXNWxJSGd4UFNJeE16QWlJSGt4UFNJeE1EQWlJSGd5UFNJeE5qQWlJSGt5UFNJeE1EQWlJSE4wY205clpUMGlZbXhoWTJzaUx6NDhiR2x1WlNCNE1UMGlNVE13SWlCNU1UMGlNVEV3SWlCNE1qMGlNVFl3SWlCNU1qMGlNVEl3SWlCemRISnZhMlU5SW1Kc1lXTnJJaTgrUEhCaGRHZ2daRDBpVFRFMU1DQXhOREFnVVRFM01DQXhNekFnTVRZd0lERXhNQ0JSTVRVd0lEa3dJREUzTUNBNE1DSWdjM1J5YjJ0bFBTSnZjbUZ1WjJVaUlITjBjbTlyWlMxM2FXUjBhRDBpT0NJZ1ptbHNiRDBpYm05dVpTSXZQand2YzNablBnPT0ifQ==";

        assertEq(keccak256(abi.encodePacked(onchainCatNFT.tokenURI(1))), keccak256(abi.encodePacked(expectedURI)));
    }
}
