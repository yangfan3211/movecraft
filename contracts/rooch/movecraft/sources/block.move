module movecraft::block {
    use movecraft::cells;
    use moveos_std::timestamp;
    use movecraft::cells::Cell;

    use moveos_std::object::{Self, Object};

    use bitcoin_move::utxo::{Self, UTXO};

    const ErrorInvalidCellId: u64 = 1;
    const ErrorAlreadyStaked: u64 = 2;
    const ErrorAlreadyClaimed: u64 = 3;

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

    /// Stake the UTXO to get the `Movecraft Cell`
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

    // TODO: Claim the `Movecraft Cell` from the UTXO
    // DO NOT DELETE THIS FUNCTION
    /// Claim the `BTC Holder Coin` from the UTXO
    public fun do_claim(utxo_obj: &mut Object<UTXO>){
        let owner = object::owner(utxo_obj);
        let utxo_value = utxo::value(object::borrow(utxo_obj));
        let stake_info = utxo::borrow_mut_temp_state<StakeInfo>(utxo_obj);
        let now = timestamp::now_seconds();
        assert!(stake_info.last_claim_time < now, ErrorAlreadyClaimed);
        let mint_amount = (now - stake_info.last_claim_time) * utxo_value;
        //TODO ensure the mint amount is correct
        cells::mint_random(owner, mint_amount);
        stake_info.last_claim_time = now;
    }

    public entry fun claim(utxo: &mut Object<UTXO>) {
        do_claim(utxo);
    }

    /// Stack two blocks together. Both blocks must be of the same type and stackable.
    /// The second block will be burned after stacking.
    // TODO: use object id as parameter instead of object.
    public entry fun stack_block(block1: Object<Cell>, block2: Object<Cell>) {
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
        cells::burn(block2);
    }


}
