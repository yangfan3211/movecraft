module movecraft::block {
    use moveos_std::account;
    use std::string;
    use movecraft::cells;
    use movecraft::collection;
    use moveos_std::timestamp;
    use movecraft::cells::NFT;

    use moveos_std::object::{Self, Object};
    use moveos_std::object::ObjectID;

    use bitcoin_move::utxo::{Self, UTXO};

    const ErrorInvalidCellId: u64 = 1000;
    const ErrorAlreadyStaked: u64 = 1001;

    const ENOT_VALID_BLOCK_TYPE: u64 = 2002;
    const ENOT_BLOCK_OWNER: u64 = 2003;
    const ENOT_VALID_BLOCK: u64 = 2004;
    const ENOT_STACKABLE: u64 = 2005;
    const ENOT_TYPEMATCH: u64 = 2006;
    const ENOT_AMOUNT_MATCH: u64= 2007;


    /// The stake info of UTXO
    /// This Info store in the temporary state area of UTXO
    /// If the UTXO is spent, the stake info will be removed
    struct StakeInfo has store, drop {
        start_time: u64,
        last_claim_time: u64,
    }

    // Router function to mint cells based on cell_id
    // TODO: make it mint randomlly, refer the `blind-box`
    public entry fun mint_cell(account: &signer, collection_obj: &mut Object<collection::Collection>, cell_id: u64) {
        assert!(cell_id <= 7, ErrorInvalidCellId); // Ensure cell_id is valid
        cells::mint_entry(collection_obj, cell_id);
    }

    /// Stake the UTXO to get the `Movecraft NFT`
    public fun do_stake(utxo: &mut Object<UTXO>) {
        assert!(!utxo::contains_temp_state<StakeInfo>(utxo), ErrorAlreadyStaked);
        let now = timestamp::now_seconds();
        let stake_info = StakeInfo { start_time: now, last_claim_time: now};
        utxo::add_temp_state(utxo, stake_info);
    }


    // Stake UTXO to mint automatically!
    public entry fun stake(utxo: &mut Object<UTXO>) {
       do_stake(utxo);
    }

    // TODO: Claim the `Movecraft NFT` from the UTXO
    // DO NOT DELETE THIS FUNCTION
    /// Claim the `BTC Holder Coin` from the UTXO
    // public fun do_claim(coin_info_holder_obj: &mut Object<CoinInfoHolder>, utxo_obj: &mut Object<UTXO>): Coin<HDC> {
    //     let utxo_value = utxo::value(object::borrow(utxo_obj));
    //     let stake_info = utxo::borrow_mut_temp_state<StakeInfo>(utxo_obj);
    //     let now = timestamp::now_seconds();
    //     assert!(stake_info.last_claim_time < now, ErrorAlreadyClaimed);
    //     let coin_info_holder = object::borrow_mut(coin_info_holder_obj);
    //     let mint_amount = (((now - stake_info.last_claim_time) * utxo_value) as u256);
    //     let coin = coin::mint_extend(&mut coin_info_holder.coin_info, mint_amount);
    //     stake_info.last_claim_time = now;
    //     coin
    // }

    // public entry fun claim(coin_info_holder_obj: &mut Object<CoinInfoHolder>, utxo: &mut Object<UTXO>) {
    //     let coin = do_claim(coin_info_holder_obj, utxo);
    //     let sender = tx_context::sender();
    //     account_coin_store::deposit(sender, coin);
    // }

    public entry fun set_block_num(nft_obj: &mut Object<NFT>, block_num: u64) {
        cells::set_block_num(nft_obj, block_num);
    }

    /// Stack two blocks together. Both blocks must be of the same type and stackable.
    /// The second block will be burned after stacking.
    public entry fun stack_block(account: &signer, collection_obj: &mut Object<collection::Collection>, block1: Object<NFT>, block2: Object<NFT>) {
        // Get properties of both blocks
        let block1_type = cells::type(object::borrow(&block1));
        let block2_type = cells::type(object::borrow(&block2));
        
        // Validate blocks are of same type
        assert!(block1_type == block2_type, ENOT_TYPEMATCH);
        
        // Get current block counts
        let block1_count = cells::block_num(object::borrow(&block1));
        let block2_count = cells::block_num(object::borrow(&block2));
        
        // Update block1's count
        cells::set_block_num(&mut block1, block1_count + block2_count);
        
        // Burn block2
        cells::burn(collection_obj, block1);
        cells::burn(collection_obj, block2);
    }
}
