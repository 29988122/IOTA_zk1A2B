# "Cows and Bulls" Zero-Knowledge Proof Project

---

## Project Overview

This project implements a simplified "Cows and Bulls" (also known as 1A2B) number-guessing game using zero-knowledge proofs (ZKPs). The game demonstrates how ZKPs can verify a user's guess against a secret number without revealing the secret itself. The project integrates:

- **Circom**: A circuit (`cows_and_bulls.circom`) that computes the game logic and enforces constraints.
- **Rust**: A program (`main.rs`) that generates a Groth16 proof for the circuit.
- **Move**: A smart contract (`verifier.move`) on the IOTA blockchain that verifies the proof.

The secret number is hardcoded as `1234` for demonstration purposes. A user submits a four-digit guess, and the system outputs:
- `isCorrect`: Whether the guess matches the secret exactly.
- `bulls`: Digits correct in both value and position.
- `cows`: Digits correct in value but in the wrong position.

This README focuses on the behavior of the provided code files, detailing their code flow and interactions.

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [Circuit Behavior (`cows_and_bulls.circom`)](#circuit-behavior-cows_and_bullscircom)
3. [Rust Proof Generation (`main.rs`)](#rust-proof-generation-mainrs)
4. [Move Verifier Contract (`verifier.move`)](#move-verifier-contract-verifiermove)
5. [Interactions Between Components](#interactions-between-components)
6. [Setup and Usage](#setup-and-usage)
7. [Limitations and Notes](#limitations-and-notes)

---

## Project Structure

The project includes the following key files:

- **`cows_and_bulls.circom`**: The Circom circuit implementing the "Cows and Bulls" game logic.
- **`guess_42.circom`**: A simple demonstration circuit that checks if an input equals 42 (used in `main.rs`).
- **`main.rs`**: A Rust program that generates a Groth16 proof (currently for `guess_42.circom`).
- **`verifier.move`**: A Move smart contract that verifies Groth16 proofs on the IOTA blockchain.

---

## Circuit Behavior (`cows_and_bulls.circom`)

The `cows_and_bulls.circom` file defines a Circom circuit that computes the "Cows and Bulls" game logic. Here's how it works:

### Inputs and Outputs
- **Public Input**: `guess[4]` – An array of four digits (e.g., `[5, 6, 7, 8]`).
- **Private Input**: `secret[4]` – Hardcoded as `[1, 2, 3, 4]`.
- **Public Outputs**:
  - `isCorrect`: 1 if `bulls == 4` (guess matches secret), 0 otherwise.
  - `bulls`: Number of digits correct in value and position.
  - `cows`: Number of digits correct in value but wrong in position.

### Code Flow
1. **Range Check**:
   - For each `guess[i]`, a `LessThan(4)` component ensures the digit is between 0 and 9.
   - Constraint: `lt_range_check[i].out === 1` fails if `guess[i] >= 10`.

2. **Bulls Calculation**:
   - For each position `i`, an `IsEqual()` component compares `guess[i]` with `secret[i]`.
   - `bulls` is the sum of these equality checks: `bulls <== eq_bulls[0].out + ... + eq_bulls[3].out`.

3. **Total Matches Calculation**:
   - For each digit `d` (0 to 9):
     - Count occurrences of `d` in `guess` (`countG_arr[d]`) and `secret` (`countS_arr[d]`) using nested `IsEqual()` components.
     - Use a custom `Min` template to compute the minimum of `countG_arr[d]` and `countS_arr[d]`.
   - `totalMatches` is the sum of these minimums across all digits (0 to 9).

4. **Cows Calculation**:
   - `cows <== totalMatches - bulls` – Subtracts bulls from total matches to get digits correct but misplaced.

5. **isCorrect Calculation**:
   - An `IsEqual()` component checks if `bulls == 4`.
   - `isCorrect <== eq4.out` outputs 1 if the guess is fully correct, 0 otherwise.

### Example
- Guess: `[1, 3, 2, 4]`
- Secret: `[1, 2, 3, 4]`
- Bulls: 2 (positions 0 and 3 match)
- Total Matches: 4 (all digits 1, 2, 3, 4 appear in both)
- Cows: 2 (4 - 2)
- isCorrect: 0 (bulls != 4)

---

## Rust Proof Generation (`main.rs`)

The `main.rs` file generates a Groth16 proof using the Arkworks library. It currently uses `guess_42.circom`, but the process applies to `cows_and_bulls.circom` with adjustments.

### Code Flow
1. **Load Circuit**:
   - Loads WASM (`guess_42.wasm`) and R1CS (`guess_42.r1cs`) files generated from Circom compilation.

2. **Set Inputs**:
   - Adds input `x = 42` to the circuit builder (specific to `guess_42.circom`).
   - For `cows_and_bulls.circom`, this would be `guess[4]` (e.g., `[1, 2, 3, 4]`).

3. **Generate Proving Key**:
   - Creates a random proving key using `Groth16::generate_random_parameters_with_reduction`.
   - Note: This is insecure for production; a trusted setup key is required.

4. **Build Circuit and Generate Proof**:
   - Builds the circuit with inputs.
   - Generates a proof using `Groth16::prove`.

5. **Verify Locally**:
   - Prepares the verifying key (`pvk`) and verifies the proof with public inputs.
   - Asserts the proof is valid.

6. **Serialize Outputs**:
   - Prints the verifying key, proof, and public inputs in hexadecimal format.

---

## Move Verifier Contract (`verifier.move`)

The `verifier.move` file is a Move smart contract on the IOTA blockchain that verifies Groth16 proofs.

### Code Flow
1. **Verifying Key**:
   - Hardcodes `VK_BYTES_FIXEDNUM` for `guess_42.circom`.
   - A commented `VK_BYTES_1A2B` placeholder exists for `cows_and_bulls.circom`.

2. **Verification Function (`verify_fixednum`)**:
   - Takes `proof_bytes` and `pub_inputs_bytes` as inputs.
   - Prepares the verifying key using `groth16::prepare_verifying_key`.
   - Converts proof and public inputs into required formats.
   - Calls `groth16::verify_groth16_proof` to verify the proof.
   - Emits a `VerifiedEvent` with the result (`true` or `false`).
   - Returns the verification result.

3. **Commented Function (`verify_1A2B`)**:
   - A template for verifying `cows_and_bulls.circom` proofs, identical to `verify_fixednum` but using `VK_BYTES_1A2B`.

---

## Interactions Between Components

The components work together as follows:

1. **Circom to Rust**:
   - Compile `cows_and_bulls.circom` to generate WASM and R1CS files.
   - Rust (`main.rs`) loads these files, sets `guess[4]`, and generates a proof.

2. **Rust to Move**:
   - Rust outputs the proof and public inputs (e.g., `[isCorrect, bulls, cows]`) in hex.
   - These are submitted to the Move contract (`verifier.move`) via a IOTA client call.

3. **Move to User**:
   - The contract verifies the proof and emits a `VerifiedEvent`.
   - The user interprets the event to determine if the guess was validly processed.

### Full Workflow
- **Step 1**: User compiles `cows_and_bulls.circom` and runs `main.rs` with a guess (e.g., `[5, 6, 7, 8]`).
- **Step 2**: Rust generates a proof and public outputs (e.g., `[0, 1, 1]` for isCorrect=0, bulls=1, cows=1).
- **Step 3**: User submits the proof and outputs to `verifier.move`.
- **Step 4**: Contract verifies and emits an event (e.g., `is_verified: true`).

---

## Setup and Usage

1. **Compile the Circom Circuit**:
   ```bash
   circom cows_and_bulls.circom --r1cs --wasm
   ```
   - Generates `cows_and_bulls.r1cs` and `cows_and_bulls.wasm`.

2. **Generate Keys**:
   - Use `snarkjs` for a trusted setup:
     ```bash
     snarkjs groth16 setup cows_and_bulls.r1cs ...
     ```
   - Update `main.rs` with the proving key.

3. **Run Rust Program**:
   - Modify `main.rs` to use `cows_and_bulls.wasm` and `cows_and_bulls.r1cs`.
   - Set `guess[4]` inputs (e.g., `builder.push_input("guess", vec![5, 6, 7, 8])`).
   - Run: `cargo run`.

4. **Deploy Move Contract**:
   - Populate `VK_BYTES_1A2B` with the verifying key from the trusted setup.
   - Uncomment and use `verify_1A2B`.
   - Deploy on IOTA: `IOTA client publish`.

5. **Submit Proof**:
   - Use the IOTA client to call `verify_1A2B` with the proof and public inputs.
