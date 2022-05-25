// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract ChainBuidlrs is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter; 

    Counters.Counter private _tokenIds;
    uint256 private _maxNumberOfTokens = 23;

    mapping(uint256 => Levels) public tokenIdToLevels;
    
    struct Levels {
        uint256 experience;
        uint256 availbility;
        uint256 chains;
        uint256 buidls;
    }

    constructor() ERC721 ("Chain Buidler", "CBDLR") {
        
    }

    function generateCharacter(uint256 tokenId) public view returns(string memory){
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="purple" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"BUIDLer",'</text>',
            '<text x="30%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Experience: ",getXp(tokenId),'</text>',
            '<text x="30%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Availbility: ",getAvail(tokenId),'</text>',
            '<text x="30%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Chains: ",getChains(tokenId),'</text>',
            '<text x="30%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Buidls: ",getBuidls(tokenId),'</text>',
            '</svg>'
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }    

    function getXp (uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId));
        return tokenIdToLevels[tokenId].experience.toString();
    }
    
    function getAvail (uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId));
        return tokenIdToLevels[tokenId].availbility.toString();
    }
    
    function getChains (uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId));
        return tokenIdToLevels[tokenId].chains.toString();
    }
    
    function getBuidls (uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId));
        return tokenIdToLevels[tokenId].buidls.toString();
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId));

        Levels memory levels = tokenIdToLevels[tokenId];

        bytes memory dataURI = abi.encodePacked(
            '{',
                '"Experience": ', levels.experience.toString(), '",',
                '"Availbility": "',levels.availbility.toString(), '",',
                '"Chains": "',levels.chains.toString(), '",',
                '"Buidls": "', levels.buidls.toString(), '"',
            '}'
        );

        return string(dataURI);
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Buidlers #', tokenId.toString(), '",',
                '"description": "Buidls on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function mint() public {
        require(_tokenIds.current() < _maxNumberOfTokens, "max tokens minted");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
    
        _safeMint(msg.sender, newItemId);
        tokenIdToLevels[newItemId] = Levels(0,0,0,0);
    
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    modifier validateTrainer (uint256 tokenId) {
        require(_exists(tokenId));
        require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");
        _;
    }

    function trainExperience(uint256 tokenId) public validateTrainer(tokenId) {
    
        Levels memory currentLevel = tokenIdToLevels[tokenId];

        tokenIdToLevels[tokenId].experience = currentLevel.experience + 1;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
    
    function setAvailability(uint256 tokenId, uint256 availbility) public validateTrainer(tokenId) {
    
        tokenIdToLevels[tokenId].availbility = availbility;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

     function setChains(uint256 tokenId, uint256 chains) public validateTrainer(tokenId) {
    
        tokenIdToLevels[tokenId].chains = chains;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
    
    function setBuidls(uint256 tokenId, uint256 buidls) public validateTrainer(tokenId) {
    
        tokenIdToLevels[tokenId].buidls = buidls;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }




}