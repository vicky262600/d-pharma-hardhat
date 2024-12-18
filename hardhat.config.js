require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */

const SEPOLIA_URL = process.env.BASESEPOLIO_RPC;
const PRIVATE_KEY = process.env.BASESEPOLIO_PRIVATE_KEY;


module.exports = {
  solidity: "0.8.28",
  networks:{
    sepolia:{
      url: SEPOLIA_URL,
      accounts: [PRIVATE_KEY],
      chainId: 84532,
    }
  }
};
