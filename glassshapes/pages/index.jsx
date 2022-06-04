import Head from 'next/head'

import { useState } from 'react'
import {NFTCard} from './components/nftCard'


const Home = () => {
  const [walletAddr, setWalletAddr] = useState("");
  const [collectionAddr, setCollectionAddr] = useState("");
  const [startToken, setStartToken] = useState("");
  const [nextToken, setNextToken] = useState("");
  const [backToken, setBackToken] = useState("");
  const [NFTs, setNFTs] = useState([]);
  const [NFTsForCollection, setNFTsForCollection] = useState(false);

  const DEBUG = false;
  const apikey = process.env.API_KEY;
  const baseGetNFTsURL = `https://eth-mainnet.alchemyapi.io/v2/${apikey}/getNFTs/`;
  const baseGetNFTsColURL = `https://eth-mainnet.alchemyapi.io/v2/${apikey}/getNFTsForCollection/`;

  var requestOptions = {
    method: 'GET'
  };

  const fetchNFTs = async() => {
    //get nfts
    let nfts;
    if (DEBUG) console.log("fetching nfts")
    

    if (!collectionAddr.length){
      const fetchURL = `${baseGetNFTsURL}?}&pageKey=${startToken}&owner=${walletAddr}`;
      nfts = await fetch(fetchURL, requestOptions).then(data=>data.json());
    } else {
      if (DEBUG) console.log("fetching nfts for collection owned by address")
      const fetchURL = `${baseGetNFTsURL}?owner=${walletAddr}&pageKey=${startToken}&contractAddresses%5B%5D=${collectionAddr}`;
      nfts = await fetch(fetchURL, requestOptions).then(data=>data.json());
    }

    if(nfts){
      if (DEBUG) console.log("nfts", nfts)
      setNFTs(nfts.ownedNfts)
      setStartToken(nfts.pagekey);
    }
 }

 const fetchNFTsForCollection = async () => {
  if(collectionAddr.length){
    
    const fetchURL =  `${baseGetNFTsColURL}?contractAddress=${collectionAddr}&startToken=${startToken}&withMetadata=${"true"}`;
    const nfts = await fetch(fetchURL, requestOptions).then(data=>data.json());
    if (nfts) {
      if (DEBUG) console.log("NFT Collection:", nfts);
      setNFTs(nfts.nfts);
      setStartToken(nfts.nextToken);
    }
  }
 }

 const getNFTs = async () => {
  if (NFTsForCollection) {
    await fetchNFTsForCollection();
  } else {
    await fetchNFTs();
  }
 }

 const resetTokens = () => {
  setStartToken("");
  setBackToken("");
  setNextToken("");
 }

  return (
    <div className="flex flex-col items-center justify-center py-8 gap-y-3">
        <div className='flex flex-col w-full justify-center items-center gap-y-2'>
          <input className="w-2/5 bg-slate-100 py-2 rounded-lg text-grey-800 focus:outline-blue-300 disabled:bg-slate-50" onChange={(e)=>{setWalletAddr(e.target.value)}} value={walletAddr} type={"text"} placeholder="Wallet Address"></input>
          <input className="w-2/5 bg-slate-100 py-2 rounded-lg text-grey-800 focus:outline-blue-300 disabled:bg-slate-50"  onChange={(e)=>{setCollectionAddr(e.target.value)}} value={collectionAddr} type={"text"} placeholder="Collection Address"></input>
          <label className="text-gray-600"><input className="mr-2" onChange={(e)=>{setNFTsForCollection(e.target.checked)}} type={"checkbox"}></input>Fetch Collection</label>
          <button className="disabled:bg-slate-500 text-white bg-blue-400 px-4 py-2 mt-3 rounded-sm w-1/5" onClick={
            () => {
              resetTokens();
              getNFTs();
            }
          }>Browse NFTs</button>
        </div>
        <div className='flex justify-center gap-y-2'>
          <button hidden={!NFTsForCollection} className="disabled:bg-slate-500 text-white bg-blue-400 px-4 py-2 mt-3 ml-4 mr-4 rounded-sm"
          onClick={
            () => {
              let i = Clng(startToken) - 100
              setStartToken(i >= 0 ? i : 0);
              getNFTs();
            }
          }> Back </button>
        
         <input hidden={!NFTsForCollection} className="w-1/5 bg-slate-100 py-2 rounded-sm text-grey-800 focus:outline-blue-300 disabled:bg-slate-50" 
            onChange={
              (e)=>{
                setStartToken(e.target.value);
              }
             } type={"text"} ></input>

         <button className="disabled:bg-slate-500 text-white bg-blue-400 px-4 py-2 mt-3 ml-4 mr-4 rounded-sm"
          onClick={
            () => {
              getNFTs();
            }
          }> Start At Token </button>      

          <button className="disabled:bg-slate-500 text-white bg-blue-400 px-4 py-2 mt-3 ml-4 mr-4 rounded-sm"
          onClick={
            () => {
              getNFTs();
            }
          }> Next </button>
        </div>

        <div className="flex flex-wrap gap-y-12 mt-4 w-5/6 gap-x-2 justify-center">
          {
            NFTs.length && NFTs.map(nft => {
              return(
                <NFTCard nft={nft}></NFTCard>
              )
            })
          }
        </div>

    </div>
  )
}

export default Home
