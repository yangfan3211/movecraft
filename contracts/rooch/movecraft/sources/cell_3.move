// Copyright (c) RoochNetwork
// SPDX-License-Identifier: Apache-2.0

module movecraft::cell_3 {
    use std::string::{Self, String};
    use movecraft::collection;
    use moveos_std::display;
    use moveos_std::object::{Self, Object};
    use moveos_std::object::ObjectID;
    use moveos_std::account;
    use moveos_std::signer;
    use moveos_std::table;
    use moveos_std::table::Table;

    use moveos_std::tx_context::sender;

    #[test_only]
    use std::option;

    const ErrorCreatorNotMatch: u64 = 1;

    struct Config has key, store{
        index: u64,
        minted_address: Table<address, ObjectID>
    }
    struct NFT has key,store {
        index: u64,
        name: String,
        collection: ObjectID,
        creator: address,
    }

    fun init(){
        let nft_display_object = display::display<NFT>();
        display::set_value(nft_display_object, string::utf8(b"creator"), string::utf8(b"leeduckgo"));
        display::set_value(nft_display_object, string::utf8(b"uri"), string::utf8(b"https://arweave.net/1WNPHI6RU0L91vDM9p6a7MY6AoGlO959iRPrle_0QAA"));
    
        let module_signer = signer::module_signer<Config>();
        let config = Config {
            index: 0,
            minted_address: table::new()
        };
        account::move_resource_to(&module_signer, config)
    
    }

    /// Mint a new NFT,
    public fun mint(
        collection_obj: &mut Object<collection::Collection>,
        index: u64,
    ): Object<NFT> {
        let collection_id = object::id(collection_obj);
        let collection = object::borrow_mut(collection_obj);
        collection::increment_supply(collection);
        //NFT's creator should be the same as collection's creator?
        let creator = collection::creator(collection);
        let nft = NFT {
            index,
            name: string::utf8(b"cell #3 #{index}"),
            collection: collection_id,
            creator,
        };
        
        let nft_obj = object::new(nft);
        nft_obj
    }

    public fun burn (
        collection_obj: &mut Object<collection::Collection>, 
        nft_object: Object<NFT>,
    ) {
        let collection = object::borrow_mut(collection_obj);
        collection::decrement_supply(collection);
        let (
            NFT {
                index:_,
                name:_,
                collection:_,
                creator:_,
            }
        ) = object::remove<NFT>(nft_object);
    }

    // view

    public fun name(nft: &NFT): String {
        nft.name
    }


    public fun collection(nft: &NFT): ObjectID {
        nft.collection
    }

    public fun creator(nft: &NFT): address {
        nft.creator
    }

    /// Mint a new NFT and transfer it to sender
    /// The Collection is shared object, so anyone can mint a new NFT
    public entry fun mint_entry(collection_obj: &mut Object<collection::Collection>) {
        let global = account::borrow_mut_resource<Config>(@movecraft);
        
        let nft_obj = mint(collection_obj, global.index);
        let nft_id = object::id(&nft_obj);
        object::transfer(nft_obj, sender());

        global.index = global.index + 1;
        table::add(&mut global.minted_address, sender(), nft_id);
    }

    #[test(sender = @nft)]
    public fun test_create_nft (sender: address){
        moveos_std::account::create_account_for_testing(sender);

        let collection_id = collection::create_collection(
            
            string::utf8(b"test_collection_name1"),
            string::utf8(b"test"),
            sender,
            string::utf8(b"test_collection_description1"),
            option::none(),
        );

        let collection_obj = object::borrow_mut_object_shared(collection_id);
        let nft_obj = mint(
            collection_obj,
            string::utf8(b"test_nft_1"),
        );
        object::transfer(nft_obj, sender);
    }

}