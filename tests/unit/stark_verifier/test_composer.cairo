//
// To run only this test suite use:
// make test TEST_PATH="stark_verifier/test_composer.cairo"
// 

%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memset import memset
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from utils.endianness import byteswap32

from stark_verifier.crypto.random import PublicCoin
from stark_verifier.air.air_instance import AirInstance, DeepCompositionCoefficients, get_deep_composition_coefficients

@external
func test_get_deep_composition_coefficients{
    range_check_ptr,
    bitwise_ptr: BitwiseBuiltin*
}() {
    alloc_locals;
    let (blake2s_ptr: felt*) = alloc();

    %{
        print('test_get_deep_composition_coefficients', ids.bitwise_ptr.address_)
    %}

    // Initialize arguments
    let (coin_ptr: PublicCoin*) = alloc();
    let (coeffs_expected: DeepCompositionCoefficients*) = alloc();
    let (air_ptr: AirInstance*) = alloc();
    %{
        from zerosync_hints import *
        from src.stark_verifier.utils import write_into_memory
        data = evaluation_data()
        write_into_memory(ids.air_ptr, data['air'], segments)
        write_into_memory(ids.coeffs_expected, data['deep_coefficients'], segments)
        write_into_memory(ids.coin_ptr, data['deep_coefficients_coin'], segments)
    %} 

    // let (seed) = alloc();
    // assert seed[0] = byteswap32( [coin_ptr].seed[0] );
    // assert seed[1] = byteswap32( [coin_ptr].seed[1] );
    // assert seed[2] = byteswap32( [coin_ptr].seed[2] );
    // assert seed[3] = byteswap32( [coin_ptr].seed[3] );
    // assert seed[4] = byteswap32( [coin_ptr].seed[4] );
    // assert seed[5] = byteswap32( [coin_ptr].seed[5] );
    // assert seed[6] = byteswap32( [coin_ptr].seed[6] );
    // assert seed[7] = byteswap32( [coin_ptr].seed[7] );


    tempvar public_coin = PublicCoin(
        seed = [coin_ptr].seed,
        counter = [coin_ptr].counter
    );

    with blake2s_ptr, public_coin {
        let coeffs = get_deep_composition_coefficients([air_ptr]);
    }

    %{
        assert True
    %}
    return ();
}


