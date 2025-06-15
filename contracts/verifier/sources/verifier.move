module verifier::verifier {
    use iota::groth16;
    use iota::event;

    const VK_BYTES_FIXEDNUM: vector<u8> = x"94d781ec65145ed90beca1859d5f38ec4d1e30d4123424bb7b0c6fc618257b1551af0374b50e5da874ed3abbc80822e4378fdef9e72c423a66095361dacad8243d1a043fc217ea306d7c3dcab877be5f03502c824833fc4301ef8b712711c49ebd491d7424efffd121baf85244404bded1fe26bdf6ef5962a3361cef3ed1661d897d6654c60dca3d648ce82fa91dc737f35aa798fb52118bb20fd9ee1f84a7aabef505258940dc3bc9de41472e20634f311e5b6f7a17d82f2f2fcec06553f71e5cd295f9155e0f93cb7ed6f212d0ccddb01ebe7dd924c97a3f1fc9d03a9eb9150200000000000000d1ab9918816459ca424af69205230d0afe4a2a802f8bd01f23e73a03359a7d28af9ecf024817d8964c4b2fed6537bcd70600a85cdec0ca4b0435788dbffd81ab";
    //const VK_BYTES_1A2B: vector<u8> = x""

    public struct VerifiedEvent has copy, drop {
        is_verified: bool,
    }

    #[allow(implicit_const_copy)]
    public fun verify_fixednum(
        proof_bytes: vector<u8>,
        pub_inputs_bytes: vector<u8>
    ): bool {
        let vk = groth16::prepare_verifying_key(&groth16::bn254(), &VK_BYTES_FIXEDNUM);
        let proof = groth16::proof_points_from_bytes(proof_bytes);
        let pub_inputs = groth16::public_proof_inputs_from_bytes(pub_inputs_bytes);

        let verifiedResult = groth16::verify_groth16_proof(
            &groth16::bn254(),
            &vk,
            &pub_inputs,
            &proof
        );
        
        event::emit(VerifiedEvent { is_verified: verifiedResult });
        
        if (!verifiedResult) {
            return false
        };
        verifiedResult
    }
 /* #[allow(implicit_const_copy)]
    public fun verify_1A2B(
        proof_bytes: vector<u8>,
        pub_inputs_bytes: vector<u8>
    ): bool {
        let vk = groth16::prepare_verifying_key(&groth16::bn254(), &VK_BYTES_1A2B);
        let proof = groth16::proof_points_from_bytes(proof_bytes);
        let pub_inputs = groth16::public_proof_inputs_from_bytes(pub_inputs_bytes);

        let verifiedResult = groth16::verify_groth16_proof(
            &groth16::bn254(),
            &vk,
            &pub_inputs,
            &proof
        );
        
        event::emit(VerifiedEvent { is_verified: verifiedResult });
        
        if (!verifiedResult) {
            return false
        };
        verifiedResult
    } */
}