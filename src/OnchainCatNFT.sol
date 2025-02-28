// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OnchainCatNFT is ERC721, Ownable {
    uint256 private nextTokenId;
    uint256 public constant MINT_PRICE = 1 ether;

    event CatMinted(address indexed recipient, uint256 tokenId, string furColor);
    event Withdrawn(address indexed owner, uint256 amount);

    error InsufficientFunds();
    error TransferFailed();
    error InvalidCall();

    constructor() ERC721("Onchain Cat NFT", "OCAT") Ownable(msg.sender) {
        nextTokenId = 1;
    }

    /**
     * @dev Mints a new Onchain Cat NFT. Requires 1 Ether payment.
     */
    function mint() public payable {
        if (msg.value < MINT_PRICE) revert InsufficientFunds();

        uint256 tokenId = nextTokenId;
        _safeMint(msg.sender, tokenId);

        unchecked {
            nextTokenId++;
        }
        emit CatMinted(msg.sender, tokenId, _getColor(tokenId));
    }

    /**
     * @dev Returns the metadata URI for a given token.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        string memory svgImage = _generateSVG(tokenId);
        string memory imageURI = string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(bytes(svgImage))));

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name": "Onchain Cat #',
                            Strings.toString(tokenId),
                            '", ',
                            '"description": "A fully on-chain generated cat NFT.", ',
                            '"attributes": [{"trait_type": "Fur Color", "value": "',
                            _getColor(tokenId),
                            '"}], ',
                            '"image": "',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    /**
     * @dev Generates the SVG image for the NFT based on token ID.
     */
    function _generateSVG(uint256 tokenId) internal pure returns (string memory) {
        string memory furColor = _getColor(tokenId);
        return string(
            abi.encodePacked(
                '<svg width="200" height="200" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">',
                '<ellipse cx="100" cy="130" rx="50" ry="60" fill="',
                furColor,
                '" />',
                '<circle cx="100" cy="80" r="40" fill="',
                furColor,
                '" />',
                '<polygon points="70,50 85,20 100,50" fill="',
                furColor,
                '"/>',
                '<polygon points="130,50 115,20 100,50" fill="',
                furColor,
                '"/>',
                '<circle cx="85" cy="75" r="6" fill="white"/>',
                '<circle cx="115" cy="75" r="6" fill="white"/>',
                '<circle cx="85" cy="75" r="3" fill="black"/>',
                '<circle cx="115" cy="75" r="3" fill="black"/>',
                '<polygon points="95,85 105,85 100,95" fill="pink"/>',
                '<path d="M100 95 Q90 110 80 100" stroke="black" fill="transparent"/>',
                '<path d="M100 95 Q110 110 120 100" stroke="black" fill="transparent"/>',
                '<line x1="70" y1="90" x2="40" y2="80" stroke="black"/>',
                '<line x1="70" y1="100" x2="40" y2="100" stroke="black"/>',
                '<line x1="70" y1="110" x2="40" y2="120" stroke="black"/>',
                '<line x1="130" y1="90" x2="160" y2="80" stroke="black"/>',
                '<line x1="130" y1="100" x2="160" y2="100" stroke="black"/>',
                '<line x1="130" y1="110" x2="160" y2="120" stroke="black"/>',
                '<path d="M150 140 Q170 130 160 110 Q150 90 170 80" stroke="',
                furColor,
                '" stroke-width="8" fill="none"/>',
                "</svg>"
            )
        );
    }

    /**
     * @dev Returns the fur color based on the token ID.
     */
    function _getColor(uint256 tokenId) internal pure returns (string memory) {
        string[6] memory colors = ["gray", "orange", "black", "red", "green", "blue"];
        return colors[tokenId % 6];
    }

    /**
     * @dev Allows contract owner to withdraw contract balance.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert InsufficientFunds();
        (bool success,) = payable(msg.sender).call{value: balance}("");

        if (!success) revert TransferFailed();

        emit Withdrawn(msg.sender, balance);
    }

    /**
     * @dev Receive function to allow direct ETH transfers for minting.
     */
    receive() external payable {
        mint();
    }

    /**
     * @dev Fallback function to handle unexpected calls.
     */
    fallback() external payable {
        revert InvalidCall();
    }
}
