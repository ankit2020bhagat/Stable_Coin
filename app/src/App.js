import { useEffect, useState } from "react";
import React from "react";
import "./styles/App.css";
import { ethers } from "ethers";
import payment from "./artifacts/contracts/Stable_coin.sol/Stablecoin.json";
import { CONTRACT_ADDRESS } from "./constant/address";

// Constants

function App() {
  const [currentAccount, setCurrentAccount] = useState("");

  const [amount, setAmount] = useState("");
  const [withDrawlAmount, setwithDrawlAmount] = useState("");
  const [ethPerUsd, setEthPerUsd] = useState("");

  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get MetaMask -> https://metamask.io/");
        return;
      }

      // Fancy method to request access to account.
      const accounts = await ethereum.request({
        method: "eth_requestAccounts",
      });

      // Boom! This should print out public address once we authorize Metamask.
      console.log("Connected", accounts[0]);
      setCurrentAccount(accounts[0]);
    } catch (error) {
      console.log(error);
    }
  };

  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      console.log("Make sure you have metamask!");
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
    }

    const accounts = await ethereum.request({ method: "eth_accounts" });

    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log("Found an authorized account:", account);
      setCurrentAccount(account);
    } else {
      console.log("No authorized account found");
    }
  };
  const deposit = async () => {
    try {
      const { ethereum } = window;
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();

        const stableCoinContracts = new ethers.Contract(
          CONTRACT_ADDRESS,
          payment.abi,
          signer
        );

        const txn = await stableCoinContracts.deposit({
          value: ethers.utils.parseEther(amount),
        });
        await txn.wait();
        totalSupply();
      }
    } catch (error) {
      console.log(error);
    }
  };
  const totalSupply = async () => {
    try {
      const { ethereum } = window;
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();

        const stableCoinContracts = new ethers.Contract(
          CONTRACT_ADDRESS,
          payment.abi,
          signer
        );
        const totalSupply = await stableCoinContracts.totalSupply();
        console.log("Total Supply ", totalSupply.toString());
      }
    } catch (error) {
      console.log(error);
    }
  };

  const redeem = async () => {
    try {
      const { ethereum } = window;
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();

        const stableCoinContracts = new ethers.Contract(
          CONTRACT_ADDRESS,
          payment.abi,
          signer
        );

        const txn = await stableCoinContracts.redeem(withDrawlAmount);
        await txn.wait();
        totalSupply();
      }
    } catch (error) {
      console.log(error);
    }
  };

  const getdetails = async () => {
    try {
      const { ethereum } = window;
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();

        const stableCoinContracts = new ethers.Contract(
          CONTRACT_ADDRESS,
          payment.abi,
          signer
        );
        const EthBalance = await stableCoinContracts.getEthBalance(
          currentAccount
        );
        console.log("Eth Balance of Current account ", EthBalance.toString());
        const nUSDBalance = await stableCoinContracts.getNusdBalance(
          currentAccount
        );
        console.log("nUSD Balance of current account ", nUSDBalance.toString());
      }
    } catch (error) {
      console.log(error);
    }
  };
  const getethprice = async () => {
    try {
      const { ethereum } = window;
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();

        const stableCoinContracts = new ethers.Contract(
          CONTRACT_ADDRESS,
          payment.abi,
          signer
        );

        const price = await stableCoinContracts.getEthPrice();
        setEthPerUsd(price.toString());
        totalSupply();
      }
    } catch (error) {
      console.log(error);
    }
  };
  const renderInputForm = () => {
    return (
      <div className="form-container">
        <div className="first-row">
          <input
            type="text"
            placeholder="depositColletral"
            onChange={(e) => setAmount(e.target.value)}
          />
          <div className="button-container">
            <button
              className="cta-button mint-button"
              disabled={null}
              onClick={deposit}
            >
              Deposit Colletal
            </button>
            <br />
          </div>
          <input
            type="text"
            placeholder="tokenAmount"
            onChange={(e) => setwithDrawlAmount(e.target.value)}
          />
        </div>

        <div className="button-container">
          <button
            className="cta-button mint-button"
            disabled={null}
            getDetails
            onClick={redeem}
          >
            Redeem
          </button>
          <button
            className="cta-button mint-button"
            disabled={null}
            getDetails
            onClick={getdetails}
          >
            Get Detials
          </button>
        </div>
      </div>
    );
  };

  const renderNotConnectedContainer = () => (
    <div className="connect-wallet-container">
      <img
        src="https://media.giphy.com/media/3ohhwytHcusSCXXOUg/giphy.gif"
        alt="Ninja donut gif"
      />
      {/* Call the connectWallet function we just wrote when the button is clicked */}
      <button
        onClick={connectWallet}
        className="cta-button connect-wallet-button"
      >
        Connect Wallet
      </button>
    </div>
  );

  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);

  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <header>
            <div className="left">
              <p className="title">🐱‍👤 Decentralized StableCoin </p>
              <p className="subtitle">Deposit ETH and mint nUSD</p>
            </div>
            <button
              onClick={getethprice}
              className="cta-button connect-wallet-button"
            >
              ETH/USD
            </button>
          </header>
          <h2>ETH/USG {ethPerUsd}</h2>
        </div>
        {!currentAccount && renderNotConnectedContainer()}
        {/* Render the input form if an account is connected */}
        {currentAccount && renderInputForm()}
      </div>
    </div>
  );
}

export default App;
