import {
  DAPP_ADDRESS,
  APTOS_FAUCET_URL,
  APTOS_NODE_URL,
  MODULE_URL,
  BLOCK_COLLECTION_NAME,
  STATE_SEED,
  APTOS_CONFIG,
  NETWORK_INFO,
} from "../config/constants";
import { useState, useEffect, useCallback } from "react";
import React from "react";
import {
  Account,
  Aptos,
  AptosConfig,
  InputGenerateTransactionPayloadData,
  Network,
} from "@aptos-labs/ts-sdk";

import { BlockType } from "../types";
import toast, { LoaderIcon } from "react-hot-toast";
import { Block } from "../types/Block";
import { BlockItem } from "../components/BlockItem";
import { useAptosWallet } from "@razorlabs/wallet-kit";

export default function Home() {
  const copyToClipboard = async () => {
    console.log("selectedBlock", selectedBlock?.token_id);
    try {
      await navigator.clipboard.writeText(
        selectedBlock?.token_id || "No Cell ID"
      );
      toast.success("Cell ID copied to clipboard!");
    } catch (err) {
      console.error("Failed to copy: ", err);
      toast.error("Failed to copy Cell ID.");
    }
  };
  const client = new Aptos(APTOS_CONFIG);

  // const { account, signAndSubmitTransaction } = useWallet();
  const { account, signAndSubmitTransaction, adapter } = useAptosWallet();

  const [isLoading, setLoading] = useState<boolean>(false);
  // const [blockType, setBlockType] = useState<number>(BlockType.Cell_0);
  const [blocks, setBlocks] = useState<Block[]>([]);
  const [selectedId, setSelectedId] = useState<number>();
  const [selectedBlock, setSelectedBlock] = useState<Block>();
  const [isStackMode, setStackMode] = useState<boolean>(false);

  const loadBlocks = async () => {
    console.log("client", client);
    if (account && account.address) {
      // try {
      setLoading(true);

      setStackMode(false);
      setSelectedId(undefined);

      const collectionAddress = await getCollectionAddr();

      const tokens = await client.getAccountOwnedTokensFromCollectionAddress({
        accountAddress: account.address.toString(),
        collectionAddress: collectionAddress,
      });

      console.log("accountAddress", account.address);
      console.log("tokens", tokens);

      const blocks = tokens.map((t) => {
        const token_data = t.current_token_data;
        const properties = token_data?.token_properties;
        console.log("token_data", token_data);
        console.log("properties", properties);
        return {
          name: token_data?.token_name || "",
          token_id: token_data?.token_data_id || "",
          token_uri: token_data?.token_uri || "",
          id: properties.id,
          type: properties.type,
          count: properties.count,
        };
      });
      console.log(tokens);
      setBlocks(blocks);
      // } catch {}

      setLoading(false);
    }
  };

  useEffect(() => {
    loadBlocks();
  }, [account]);

  async function getCollectionAddr() {
    const payload = {
      function: DAPP_ADDRESS + `::block::get_collection_address`,
      type_arguments: [],
      arguments: [],
    };
    const res = await client.view({ payload: payload });
    console.log("collectionAddr", res[0]);
    return res[0];
  }
  useEffect(() => {
    console.log("Adapter changed:", adapter);
  }, [adapter]);
  const handleMintBlock = useCallback(async () => {
    console.log("Current adapter:", adapter);
    console.log("Current account:", account);
    if (adapter) {
      await adapter.features["aptos:changeNetwork"]?.changeNetwork(
        NETWORK_INFO
      );
    }

    if (!account) {
      toast.error("You need to connect wallet");
      return;
    }

    const toastId = toast.loading("Minting block...");
    console.log(account);
    // // Mint block by randomlly type
    // public entry fun mint_to(creator: &signer, to: address) acquires State {

    try {
      const payloads = {
        type: "entry_function_payload",
        function: DAPP_ADDRESS + "::block::mint",
        typeArguments: [],
        functionArguments: [],
        // mint to signer as default.
      };
      const tx = await signAndSubmitTransaction({
        gasUnitPrice: 100,
        payload: payloads as unknown as InputGenerateTransactionPayloadData,
      });
      console.log(tx);

      toast.success("Minting block successed...", {
        id: toastId,
      });

      setTimeout(() => {
        loadBlocks();
      }, 3000);
    } catch (ex) {
      console.log(ex);
      toast.error("Minting block failed...", {
        id: toastId,
      });
    }
  }, [adapter, account]);

  const handleBurnBlock = async () => {
    if (!account) {
      toast.error("You need to connect wallet");
      return;
    }

    if (!selectedId) {
      toast.error("You need to select burn block");
      return;
    }

    const toastId = toast.loading("Burning block...");

    try {
      const payloads = {
        type: "entry_function_payload",
        function: DAPP_ADDRESS + "::block::burn_block",
        type_arguments: [],
        arguments: [selectedId],
      };

      const tx = await signAndSubmitTransaction(payloads, {
        gas_unit_price: 100,
      });
      console.log(tx);

      toast.success("Burning block successed...", {
        id: toastId,
      });
      setSelectedId(undefined);

      setTimeout(() => {
        loadBlocks();
      }, 3000);
    } catch (ex) {
      console.log(ex);
      toast.error("Burning block failed...", {
        id: toastId,
      });
    }
  };

  const handleStackBlock = async (otherBlock: Block) => {
    if (!account) {
      toast.error("You need to connect wallet");
      return;
    }

    if (!selectedId) {
      toast.error("You need to select start block");
      return;
    }

    console.log("selected Block", selectedBlock?.type);
    console.log("otherBlock", otherBlock.type);

    if (selectedBlock?.type !== otherBlock.type) {
      toast.error("Only blocks of the same type can be stacked ≽^-⩊-^≼~");
      return;
    }

    const toastId = toast.loading("Stacking block...");

    try {
      const payloads = {
        type: "entry_function_payload",
        function: DAPP_ADDRESS + "::block::stack_block",
        type_arguments: [],
        arguments: [selectedId, otherBlock.id],
      };

      const tx = await signAndSubmitTransaction(payloads, {
        gas_unit_price: 100,
      });
      console.log(tx);

      toast.success("Stacking block succeeded...", {
        id: toastId,
      });
      setSelectedId(undefined);

      setTimeout(() => {
        loadBlocks();
      }, 3000);
    } catch (ex) {
      console.log(ex);
      toast.error("Stacking block failed...", {
        id: toastId,
      });
    }
  };

  const handleSelect = (block: Block) => {
    if (isStackMode) {
      if (selectedId != block.id) {
        handleStackBlock(block);
      }
    } else {
      if (selectedId != block.id) {
        setSelectedBlock(block);
        setSelectedId(block.id);
      } else {
        setSelectedId(undefined);
      }
    }
  };

  return (
    <div>
      {/* 
     [x] Mint Block with smart contract 
     2/ Stack the block
     3/ Gallery to show the blocks
    */}
      <center>
        <p>
          <b>Module Path: </b>
          <a target="_blank" href={MODULE_URL} className="underline">
            {DAPP_ADDRESS}::movecraft
          </a>
        </p>

        {
          <div className="my-4">
            {/* TODO: YI with diff colors */}
            <h4>
              ꂖꈠꅁꀦꄃꇐꅐꅃ <b>ALL CELLS!</b> ꂖꈠꅁꀦꄃꇐꅐꅃ
            </h4>
            <br></br>
            <div className="flex gap-4 items-center justify-center">
              {/* bold the YI language */}
              {/*const URI: vector<u8> = b"ZSuRY-jNPllbaPAWKLfGUPRv-5_QCP8Rya2sskqfqyc";
              const URI: vector<u8> = b"m2FUu-9_-qFw91eM5ft9N07QyUJzrtiT7lCBhtvU5BA";
              const URI: vector<u8> = b"3z0hO8mspZ7uihEpAVoo7xbOrYIlKYwwtQKFvd0t11s";
              const URI: vector<u8> = b"h5PywMJR0_7TfGYjBcYHTtclpd1kP26XOM1m9VFIUQc";
              const URI: vector<u8> = b"Q4GjxhumU1s621b4F1rCWJkzIEpuMiS4KrRttuL3F-c";
              const URI: vector<u8> = b"5QPqZsLb9CbpHqIojZGNXf6QkLB5FGB4_qjbFGDEn4E";
              const URI: vector<u8> = b"NwWHZeliXk7UIwjUnCCw35vKEhBd8KTbd591jInMhRw";
              const URI: vector<u8> = b"tc9aNgx5OxcFoC9IuCadqnDUHIq1i036u2qgqdW77Pw"; */}

              <img
                style={{ width: "10%" }}
                src="https://arweave.net/7xopmyHOuhNtH2UXomaCt8m3FK42EzJ8Fb8MuGtXU58"
              ></img>
              <img
                style={{ width: "10%" }}
                src="https://arweave.net/vKq1vpQ2gR05Hf9Nn50Ut-0j2BhtOwzBnUxxDNCuTXA"
              ></img>
              <img
                style={{ width: "10%" }}
                src="https://arweave.net/y8aRTqcRdvBmI6DwJ7_RgK22U2tcsD97vQ8Mz64IGn0"
              ></img>
              <img
                style={{ width: "10%" }}
                src="https://arweave.net/1WNPHI6RU0L91vDM9p6a7MY6AoGlO959iRPrle_0QAA"
              ></img>
              <img
                style={{ width: "10%" }}
                src="https://arweave.net/pPX-WLBK-CfLe_TdE-Bm7QURuUvFIEwok9tc_aGQjrM"
              ></img>
              <img
                style={{ width: "10%" }}
                src="https://arweave.net/IynWqymNQoSPeIjGjV0I1vhXp9mCiOzyB6F9Pbd1aoQ"
              ></img>
              <img
                style={{ width: "10%" }}
                src="https://arweave.net/uZAmafyXBL8KFeIWuLi6P3jSeRZke7oVnuAMRgup0_k"
              ></img>
              <img
                style={{ width: "10%" }}
                src="https://arweave.net/GokPo_tEy0AYT1RUrHm9fz0J29cQ0eEmYt4CT5kuq5I"
              ></img>
            </div>
            <br></br>
            <div className="flex gap-4 items-center justify-center">
              {/* list block types */}
              <button
                type="button"
                className="bg-blue-500 rounded-md text-white px-4 py-2 hover:bg-blue-600"
                onClick={handleMintBlock}
              >
                Mint Block Randomly!
              </button>

              <button
                type="button"
                className="bg-blue-500 rounded-md text-white px-4 py-2 hover:bg-blue-600"
                onClick={loadBlocks}
              >
                Load Blocks
              </button>

              {selectedId && (
                <>
                  {/* <button
                    type="button"
                    className="bg-red-500 rounded-md text-white px-4 py-2 hover:bg-red-600"
                    onClick={handleBurnBlock}
                  >
                    Burn Block
                  </button> */}
                  <button
                    type="button"
                    className="bg-green-500 rounded-md text-white px-4 py-2 hover:bg-green-600"
                    onClick={() => setStackMode(!isStackMode)}
                  >
                    {isStackMode ? "Cancle Stack" : "Stack Block"}
                  </button>

                  <button
                    type="button"
                    className="bg-green-500 rounded-md text-white px-4 py-2 hover:bg-green-600"
                    onClick={() => copyToClipboard()}
                  >
                    Copy Cell ID
                  </button>
                </>
              )}
            </div>

            <br></br>
            <br></br>
            <div className="flex gap-4 items-center justify-center">
              {isLoading ? (
                <LoaderIcon className="!w-8 !h-8" />
              ) : (
                blocks.map((block, idx) => (
                  <BlockItem
                    key={idx}
                    block={block}
                    selectedId={selectedId}
                    isStackMode={isStackMode}
                    handleSelect={handleSelect}
                  />
                ))
              )}
            </div>
          </div>
        }
      </center>
    </div>
  );
}
