module movecraft::block {
    use moveos_std::account;
    use std::string;
    use movecraft::cell_0;
    use movecraft::cell_1;
    use movecraft::cell_2;
    use movecraft::cell_3;
    use movecraft::cell_4;
    use movecraft::cell_5;
    use movecraft::cell_6;
    use movecraft::cell_7;
    use movecraft::collection;
    use moveos_std::timestamp;

    use moveos_std::object::{Self, Object};
    use moveos_std::object::ObjectID;

    use bitcoin_move::utxo::{Self, UTXO};

    const ErrorInvalidCellId: u64 = 1000;

    const ErrorAlreadyStaked: u64 = 1001;


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

        if (cell_id == 0) {
            cell_0::mint_entry(collection_obj)
        } else if (cell_id == 1) {
            cell_1::mint_entry(collection_obj)
        } else if (cell_id == 2) {
            cell_2::mint_entry(collection_obj)
        } else if (cell_id == 3) {
            cell_3::mint_entry(collection_obj)
        } else if (cell_id == 4) {
            cell_4::mint_entry(collection_obj)
        } else if (cell_id == 5) {
            cell_5::mint_entry(collection_obj)
        } else if (cell_id == 6) {
            cell_6::mint_entry(collection_obj)
        } else if (cell_id == 7) {
            cell_7::mint_entry(collection_obj)
        };
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



}