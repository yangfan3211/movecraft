module movecraft::cells {
    use std::string::{Self, String};
    use std::vector;
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
    const ErrorInvalidCellType: u64 = 2;

    struct NFT has key, store, drop {
        index: u64,
        name: String,
        collection: ObjectID,
        creator: address,
        block_num: u64,
        type: u64,
    }

    struct Config has key, store {
        indices: vector<u64>,
        minted_addresses: vector<Table<address, ObjectID>>
    }

    fun init() {
        let uris = vector[
            b"https://arweave.net/7xopmyHOuhNtH2UXomaCt8m3FK42EzJ8Fb8MuGtXU58",
            b"https://arweave.net/vKq1vpQ2gR05Hf9Nn50Ut-0j2BhtOwzBnUxxDNCuTXA",
            b"https://arweave.net/y8aRTqcRdvBmI6DwJ7_RgK22U2tcsD97vQ8Mz64IGn0",
            b"https://arweave.net/1WNPHI6RU0L91vDM9p6a7MY6AoGlO959iRPrle_0QAA",
            b"https://arweave.net/pPX-WLBK-CfLe_TdE-Bm7QURuUvFIEwok9tc_aGQjrM",
            b"https://arweave.net/IynWqymNQoSPeIjGjV0I1vhXp9mCiOzyB6F9Pbd1aoQ",
            b"https://arweave.net/uZAmafyXBL8KFeIWuLi6P3jSeRZke7oVnuAMRgup0_k",
            b"https://arweave.net/GokPo_tEy0AYT1RUrHm9fz0J29cQ0eEmYt4CT5kuq5I"
        ];

        let i = 0;
        let indices = vector[];
        let minted_addresses = vector[];
        while (i < 8) {
            let nft_display_object = display::display<NFT>();
            display::set_value(nft_display_object, string::utf8(b"creator"), string::utf8(b"leeduckgo"));
            display::set_value(nft_display_object, string::utf8(b"uri"), string::utf8(*vector::borrow(&uris, i)));
            vector::push_back(&mut indices, 0);
            vector::push_back(&mut minted_addresses, table::new());
            i = i + 1;
        };

        let module_signer = signer::module_signer<Config>();
        let config = Config {
            indices,
            minted_addresses
        };
        account::move_resource_to(&module_signer, config)
    }

    /// Mint a new NFT
    public fun mint(
        collection_obj: &mut Object<collection::Collection>,
        cell_type: u64,
        index: u64,
    ): Object<NFT> {
        assert!(cell_type < 8, ErrorInvalidCellType);
        
        let collection_id = object::id(collection_obj);
        let collection = object::borrow_mut(collection_obj);
        collection::increment_supply(collection);
        let creator = collection::creator(collection);
        
        let nft = NFT {
            index,
            name: string::utf8(b"cell #"),
            collection: collection_id,
            creator,
            block_num: 1,
            type: cell_type,
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
                block_num:_,
                type:_,
            }
        ) = object::remove<NFT>(nft_object);
    }


    public fun set_block_num(nft_obj: &mut Object<NFT>, block_num: u64) {
        let nft = object::borrow_mut(nft_obj);
        nft.block_num = block_num;
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

    public fun block_num(nft: &NFT): u64 {
        nft.block_num
    }

    public fun type(nft: &NFT): u64 {
        nft.type
    }

    public fun index(nft: &NFT): u64 {
        nft.index
    }

    /// Mint a new NFT and transfer it to sender
    public entry fun mint_entry(
        collection_obj: &mut Object<collection::Collection>,
        cell_type: u64
    ) {
        assert!(cell_type < 8, ErrorInvalidCellType);
        
        let global = account::borrow_mut_resource<Config>(@movecraft);
        let index = *vector::borrow(&global.indices, cell_type);
        
        let nft_obj = mint(collection_obj, cell_type, index);
        let nft_id = object::id(&nft_obj);
        object::transfer(nft_obj, sender());

        *vector::borrow_mut(&mut global.indices, cell_type) = index + 1;
        table::add(vector::borrow_mut(&mut global.minted_addresses, cell_type), sender(), nft_id);
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