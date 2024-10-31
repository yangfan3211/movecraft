import Image from "next/image";
import { NavItem } from "./NavItem";
// import { AptosConnect } from "./AptosConnect";
import {
  APTOS_NODE_URL,
  MODULE_URL,
  NETWORK,
  NETWORK_TYPE,
  SUZUKA_CHAIN_ID
} from "../config/constants";
import { AptosChainId, AptosConnectButton, useAptosWallet } from '@razorlabs/wallet-kit';
import { ChainId, Network, NetworkToChainId } from "@aptos-labs/ts-sdk";

export function NavBar() {
  const {adapter} = useAptosWallet()
  return (
    <nav className="navbar py-4 px-4 bg-base-100">
      <div className="flex-1">
        <a href="http://movedid.build" target="_blank">
          <Image src="/logo.png" width={64} height={64} alt="logo" />
        </a>
        <ul className="menu menu-horizontal p-0 ml-5">
          <NavItem href="/" title="MoveCraft" />
          <NavItem href="/craft_example" title="Gen Capy Example" />
          <NavItem href="/music_example" title="Gen Music Example" />
          <li className="font-sans font-semibold text-lg">
            <a href="https://github.com/rootMUD/aptoscraft" target="_blank">Source Code</a>
            <a href={MODULE_URL} target="_blank">Contract on Explorer</a>
          </li>
        </ul>
      </div>
      {/* <AptosConnect /> */}
      <AptosConnectButton  onConnectSuccess={() => {
        adapter?.features["aptos:changeNetwork"]?.changeNetwork({
          name: NETWORK === "testnet" ? Network.TESTNET : Network.MAINNET,
          chainId: NETWORK_TYPE ==='aptos'? NetworkToChainId[Network.TESTNET]:SUZUKA_CHAIN_ID,
          url: APTOS_NODE_URL,
        });
      }}
      />
    </nav>
  );
}
