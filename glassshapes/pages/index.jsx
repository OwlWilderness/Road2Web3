import Head from 'next/head'
import Image from 'next/image'
import { useState } from 'react'

const Home = () => {
  const [walletAddr, setWalletAddr] = useState("");
  const [collectionAddr, setCollectionAddr] = useState("");
  const [NFTs, setNFTs] = useState([]);

  const DEBUG = true;
  const apikey = process.env.API_KEY
  const baseURL = `https://eth-mainnet.alchemyapi.io/v2/${apikey}/getNFTs/`;

  const fetchNFTs = async() => {
    //get nfts
    let nfts;
    if (DEBUG) console.log("fetching nfts")
    
    var requestOptions = {
      method: 'GET'
    };

    if (!collectionAddr.length){
      const fetchURL = `${baseURL}?owner=${walletAddr}`;
      nfts = await fetch(fetchURL, requestOptions).then(data=>data.json());
    } else {
      if (DEBUG) console.log("fetching nfts for collection owned by address")
      const fetchURL = `${baseURL}?owner=${walletAddr}&contractAddresses%5B%5D=${collectionAddr}`;
      nfts = await fetch(fetchURL, requestOptions).then(data=>data.json());
    }

    if(nfts){
      if (DEBUG) console.log("nfts", nfts)
      setNFTs(nfts.ownedNfts)
      //@@video 40:59 https://www.youtube.com/watch?v=JzsTfOFjC1o
    }



    // by address

    //fildtered by collection
  }

  return (
    <div className="flex min-h-screen flex-col items-center justify-center py-2">
        <div>
                 
          <input onChange={(e)=>{setWalletAddr(e.target.value)}} value={walletAddr} type={"text"} placeholder="Wallet Address"></input>
          <input onChange={(e)=>{setCollectionAddr(e.target.value)}} value={collectionAddr} type={"text"} placeholder="Collection Address"></input>
          <label><input type={"checkbox"}></input></label>
          <button onClick={
            () => {
              fetchNFTs();
            }
          }>Click ME</button>
        </div>
    </div>
  )
}

export default Home
