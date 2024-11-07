import { AptosConfig, Network, NetworkToChainId } from "@aptos-labs/ts-sdk";

export const NFT_STORAGE_KEY = process.env.NEXT_PUBLIC_NFT_STORAGE_KEY!;
export const SUPABASE_KEY = process.env.NEXT_PUBLIC_SUPABASE_KEY!;
export const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL!;

export const DAPP_NAME = process.env.NEXT_PUBLIC_DAPP_NAME!; // changed here.
export const DAPP_ADDRESS = process.env.NEXT_PUBLIC_DAPP_ADDRESS!; // changed here.
export const MARKET_COINT_TYPE = process.env.NEXT_PUBLIC_MARKET_COIN_TYPE!;
export const SUZUKA_CHAIN_ID = 27;
export const APTOS_NODE_URL = process.env.NEXT_PUBLIC_APTOS_NODE_URL!;
export const NETWORK = process.env.NEXT_PUBLIC_APTOS_NETWORK!;
export const NETWORK_TYPE = process.env.NEXT_PUBLIC_NETWORK_TYPE!;
export const NETWORK_INFO = {
  name: NETWORK === "testnet" ? Network.TESTNET : Network.MAINNET,
  chainId: NETWORK_TYPE ==='aptos'? NetworkToChainId[Network.TESTNET]:SUZUKA_CHAIN_ID,
  url: APTOS_NODE_URL,
}
export const APTOS_FAUCET_URL = process.env.NEXT_PUBLIC_APTOS_FAUCET_URL!;
export const APTOS_EXPLORER_URL = process.env.NEXT_PUBLIC_APTOS_EXPLORER_URL!;

export const MODULE_URL = `${APTOS_EXPLORER_URL}/account/${DAPP_ADDRESS}/modules?network=${NETWORK}`;


export const ETH_SIGNER_URL = "https://eth-signer-react-app.vercel.app/?msg=";
export const APTOS_SIGNER_URL = "https://aptos-signer.vercel.app/?msg=";

export const BLOCK_COLLECTION_NAME = "Block";

export const CAPY_COLLECTION_NAME = "CAPY COLLECTION";

export const STATE_SEED = "movecraft_signer";
export const MINT_SEED = "mint_signer";
export const BURN_SEED = "burn_signer";
export const CAPY_STATE_SEED = "capy_v4_signer";

export const APTOS_CONFIG = new AptosConfig({
  network: NETWORK === "testnet" ? Network.TESTNET : Network.MAINNET,
  fullnode: APTOS_NODE_URL,
  faucet: APTOS_FAUCET_URL,
  indexer: "https://indexer.testnet.porto.movementnetwork.xyz/v1/graphql"
});
