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
from stark_verifier.air.air_instance import AirInstance, DeepCompositionCoefficients, get_deep_composition_coefficients, TraceCoefficients

@external
func test_get_deep_composition_coefficients{
    range_check_ptr,
    bitwise_ptr: BitwiseBuiltin*
}() {
    alloc_locals;

    let (blake2s_ptr: felt*) = alloc();

    // Initialize arguments
    let (local coin_ptr: PublicCoin*) = alloc();
    let (local coeffs_expected_ptr: DeepCompositionCoefficients*) = alloc();
    let (local air_ptr: AirInstance*) = alloc();
    local deep_coefficients_trace_len;
    local deep_coefficients_constraints_len;
    %{
        from zerosync_hints import *
        from src.stark_verifier.utils import write_into_memory
        data = evaluation_data()
        write_into_memory(ids.air_ptr, data['air'], segments)
        write_into_memory(ids.coeffs_expected_ptr, data['deep_coefficients'], segments)
        write_into_memory(ids.coin_ptr, data['deep_coefficients_coin'], segments)
        ids.deep_coefficients_trace_len = int(data['deep_coefficients_trace_len'])
        ids.deep_coefficients_constraints_len = int(data['deep_coefficients_constraints_len'])
    %}


    let (seed) = alloc();
    assert seed[0] = byteswap32( [coin_ptr].seed[0] );
    assert seed[1] = byteswap32( [coin_ptr].seed[1] );
    assert seed[2] = byteswap32( [coin_ptr].seed[2] );
    assert seed[3] = byteswap32( [coin_ptr].seed[3] );
    assert seed[4] = byteswap32( [coin_ptr].seed[4] );
    assert seed[5] = byteswap32( [coin_ptr].seed[5] );
    assert seed[6] = byteswap32( [coin_ptr].seed[6] );
    assert seed[7] = byteswap32( [coin_ptr].seed[7] );
    
    let public_coin = PublicCoin(
        seed = seed,
        counter = [coin_ptr].counter
    );

    with blake2s_ptr, public_coin {
        let coeffs = get_deep_composition_coefficients([air_ptr]);
    }

    let coeffs_expected = [coeffs_expected_ptr];
    %{
        for i in range(ids.deep_coefficients_trace_len):
            addrA = ids.coeffs_expected.trace.address_ + i * ids.TraceCoefficients.SIZE
            ptrA = memory[addrA + 1]
            addrB = ids.coeffs.trace.address_ + i * ids.TraceCoefficients.SIZE
            ptrB = memory[addrB + 1]
            assert memory[addrA] == memory[addrB]
            for j in range(memory[addrA]):
                elemA = memory[ptrA + j]
                elemB = memory[ptrB + j]
                assert elemA == elemB, f"at index {i}, {j}: {hex(elemA)} != {hex(elemB)}"

        for i in range(ids.deep_coefficients_constraints_len):
            elemA = memory[ids.coeffs_expected.constraints + i]
            elemB = memory[ids.coeffs.constraints + i]
            assert elemA == elemB, f"at index {i}: {hex(elemA)} != {hex(elemB)}"
    %}


    let _lambda = coeffs.degree[0];
    let mu = coeffs.degree[1];
    let lambda_expected = coeffs_expected.degree[0];
    let mu_expected = coeffs_expected.degree[1];
    %{
        assert ids._lambda == ids.lambda_expected, f"{ids._lambda} != {ids.lambda_expected}"
        assert ids.mu == ids.mu_expected, f"{ids.mu} != {ids.mu_expected}"
    %}

    return ();
}


