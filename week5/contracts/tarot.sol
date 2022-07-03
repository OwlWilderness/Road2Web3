// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//chainlink contracts
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
//chainlink random number
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


contract GnarDGoon is ERC721, ERC721Enumerable, ERC721URIStorage,
                        Ownable, KeeperCompatibleInterface, VRFConsumerBaseV2{

    using Counters for Counters.Counter;

    VRFCoordinatorV2Interface COORDINATOR;
    // Your subscription ID.
    uint64 s_subscriptionId;

    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 500000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords =  1;

    uint256[] public s_randomWords;
    uint256 public s_randomMod2  = 0;
    uint256 public s_requestId;

    string public lastWvrp = "goon";
    string public wvrp = "gnar";
    
    address s_owner;

    //CHAINLINK KEEPER COMPATIbLE INTERFACE
    //https://docs.chain.link/docs/chainlink-keepers/compatible-contracts/
    /**
    * Public counter variable
    */
    uint public counter;

    /**
    * Use an interval in seconds and a timestamp to slow execution of Upkeep
    */
    uint public /*immutable*/ interval;
    uint public lastTimeStamp;
    int256 public currentPrice;


    //reference to chainlink aggragator and random number contract;
    AggregatorV3Interface public priceFeed;


    //private variables
    Counters.Counter private _tokenIdCounter;


    //metadata for nfts
    // gnar and goon/nay uris - note glitch is in both
    //use chain link randomness to select random metadata
    //VRFConsermerBaseV2 - add state variables, add values, pass in chain link subscription id
    //increate gas - 500000
    string[] gnarUrisIpfs = [
        "https://ipfs.io/ipfs/QmV8b3UcQPQvUWwDohVE7k61Pg75yNVpxtkKKUsGmqp1DG?filename=WVRPS-ENCORE-001.json",
        "https://ipfs.io/ipfs/QmQdzwR52teXKffzSTowAeJPuaZCMMn5FgEER8gLi6iK6C?filename=WVRP-9113.json",
        "https://ipfs.io/ipfs/QmPTuHqkFupE7fGUCSB8XvDjhoX7RxiBbvZEwtGcsRsj6C?filename=WVRP-9777.json"
    ];

    string[] nayGoonUrisIpfs = [
        "https://ipfs.io/ipfs/QmV8b3UcQPQvUWwDohVE7k61Pg75yNVpxtkKKUsGmqp1DG?filename=WVRPS-ENCORING-001.json",
        "https://ipfs.io/ipfs/QmUpCo4zMZVQpmyVUJzWrhpqW3NMMjn3hEyU7dRJsUGtw1?filename=WVRP-678.json",
        "https://ipfs.io/ipfs/QmRdhLa9JC7VQCbXjgurSpvr1V2HpX3AHXZKV8zkLN8LHL?filename=WVRP-2360.json"
    ];

//events
//*
//*
    event RandomWordFulfilled (uint256[] randomWords, uint256 randomWordMod2);
    event TokensUpdated(string, uint256);
//constructor
//*
//*

    constructor(uint updateInterval, address _priceFeed, uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) ERC721("GnarDGoon", "GNDG") {
        interval = updateInterval;
        lastTimeStamp = block.timestamp;

        //support chainlink randomness
        //https://vrf.chain.link/
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;        

        // set the price feed address to
        // BTC/USD Price Feed Contract Address on Rinkeby: https://rinkeby.etherscan.io/address/0xECe365B379E1dD183B20fc5f022230C044d51404
        // ETH / USD Rinkeby 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // or the MockPriceFeed Contract
        priceFeed = AggregatorV3Interface(_priceFeed);
        currentPrice = getLatestPrice();
        counter = 0;    
    }

//public funcitons
//*
//*
    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        string memory defaultUri = gnarUrisIpfs[0];
        _setTokenURI(tokenId, defaultUri);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();

        return price;
    }

//public helpers
//*
//*
    function setInterval(uint256 newInterval) public onlyOwner {
        interval = newInterval;
    }

    function setPriceFeed(address newFeed) public onlyOwner {
        priceFeed = AggregatorV3Interface(newFeed);
    }    

//external 
//*
//*
    //Chain Link Keeper Support
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    //chainlink keeper upkeep - execute when interval has elapsed
    function performUpkeep (bytes calldata /* performData */) external override {
        if ((block.timestamp - lastTimeStamp) < interval) {
            return; //interval not elappsed
        }
        
        // get last time stamp and latest price
        lastTimeStamp = block.timestamp;
        int latestPrice = getLatestPrice();

        //nothing to see here price has not changed
        if(latestPrice == currentPrice) {
            return;
        }

        //update wvrp based on current market trend
        lastWvrp = wvrp;
        if (latestPrice < currentPrice){
            wvrp = "gnar";
        } else {
            wvrp = "goon";
        }
        currentPrice = latestPrice;

        //request random number from chainlink vrf
        //https://vrf.chain.link/rinkeby
        requestRandomWords();
       
    }
//internal 
//*
//*
//internal helpers
    function stringEqual(string memory a, string memory b) internal pure returns(bool){
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

//internal methods
    //update token uris for wvrp and random number
    function updateAllTokenUris() internal {
        
        //determine uri based on wvrp
        string memory uri;
        if(stringEqual("gnar", wvrp)){
            uri = gnarUrisIpfs[s_randomMod2];
        } else {
            uri = nayGoonUrisIpfs[s_randomMod2];
        }

        //update each token uri
        for (uint i = 0; i < _tokenIdCounter.current(); i++){
            _setTokenURI(i,uri);
        } 

        emit TokensUpdated(wvrp,s_randomMod2);
    }

//chainlink VRF
    //support for chainlink randomness
    function requestRandomWords() internal onlyOwner {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
    }    

    //update the token when the random number request is fufilled 
    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords; 
        uint256 randomMod2 = (randomWords[0] % 2) ;
        
        if((randomMod2 == s_randomMod2) && (stringEqual(wvrp,lastWvrp))){
            //do not update if random number and wvrp have not changed
            return;
        }
        s_randomMod2 = randomMod2 ;
        updateAllTokenUris();
    }

//solidity required 
//*
//*
    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}