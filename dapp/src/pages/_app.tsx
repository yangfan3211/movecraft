import "../styles/globals.css";
import "../styles/loading.css";
import "../styles/select-input.css";
import { NavBar } from "../components/NavBar";
import type { AppProps } from "next/app";
import { useMemo, useState } from "react";
// import {
//   FewchaWalletAdapter,
//   PontemWalletAdapter,
//   MartianWalletAdapter,
//   WalletProvider,
//   AptosWalletAdapter,
// } from "@manahippo/aptos-wallet-adapter";
import { ModalContext, ModalState } from "../components/ModalContext";
import { Toaster } from "react-hot-toast";
import { AptosChainId, AptosWalletProvider, Chain } from "@razorlabs/wallet-kit";
import "@razorlabs/wallet-kit/style.css";
import 'dotenv/config'
import { APTOS_NODE_URL } from "../config/constants";

function WalletSelector({ Component, pageProps }: AppProps) {
  const [modalState, setModalState] = useState<ModalState>({
    walletModal: false,
  });
  // const wallets = useMemo(
  //   () => [
  //     new AptosWalletAdapter(),
  //     new MartianWalletAdapter(),
  //     new PontemWalletAdapter(),
  //     new FewchaWalletAdapter(),
  //   ],
  //   []
  // );
  // const modals = useMemo(
  //   () => ({
  //     modalState,
  //     setModalState: (modalState: ModalState) => {
  //       setModalState(modalState);
  //     },
  //   }),
  //   [modalState]
  // );
  const AptosTestnetChain: Chain = {
    id: AptosChainId.TEST_NET,
    name: 'Movement Aptos Testnet',
    rpcUrl: APTOS_NODE_URL,
  };
  return (
    // <WalletProvider wallets={wallets} autoConnect={false}>
    <AptosWalletProvider chains={[AptosTestnetChain]} autoConnect>
      {/* <ModalContext.Provider value={modals}> */}
        <div className="px-8">
          <NavBar />
          <Component {...pageProps} className="bg-base-300" />
          <Toaster />
        </div>
      {/* </ModalContext.Provider> */}
    </AptosWalletProvider>
    // </WalletProvider>
  );
}

export default WalletSelector;
