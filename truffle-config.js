module.exports = {
    networks: {
      development: {
        host: "127.0.0.1",
        port: 7545, // Replace with your Ganache or local Ethereum network port
        network_id: "*",
      },
    },
    compilers: {
      solc: {
        version: "0.8.16", // Specify the Solidity compiler version
      },
    },
  };
  