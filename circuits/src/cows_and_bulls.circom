pragma circom 2.1.5;

// 1A2B Number Guessing Circuit: Compares public input guess[4] (four digits) with fixed secret 1234,
// Outputs:
//  1) isCorrect (boolean): 1 when guessed correctly (bulls == 4), 0 otherwise
//  2) bulls (A): Number of digits that are correct in both value and position
//  3) cows (B): Number of digits that are correct in value but wrong in position

include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/mux1.circom";

// Calculate min(a,b)
template Min() {
signal input a;
signal input b;
signal output out;


component lt = LessThan(4);
lt.in[0] <== a;
lt.in[1] <== b;

component mux = Mux1();
mux.s <== lt.out;
mux.c[0] <== b;
mux.c[1] <== a;

out <== mux.out;


}

template Reveal1A2B() {
// Public input
signal input guess[4];
// Public output
signal output isCorrect;
signal output bulls;
signal output cows;
// Private input: secret answer
signal secret[4];

// Component and signal declarations for use in loops
component lt_range_check[4];   // For range check loop
component eq_bulls[4];         // For bulls calculation loop

signal totalMatches;           // For total matches calculation (already okay)
signal countG_arr[10];         // For 'd' loop in totalMatches
signal countS_arr[10];         // For 'd' loop in totalMatches
component eqG_components[10][4]; // For inner 'i' loop (guess side)
component eqS_components[10][4]; // For inner 'i' loop (secret side)
component min_components[10];  // For 'd' loop (Min component)


// Fixed secret is 1,2,3,4
secret[0] <== 1;
secret[1] <== 2;
secret[2] <== 3;
secret[3] <== 4;

// Range check: ensure guess[i] is between 0..9
for (var i = 0; i < 4; i++) {
    lt_range_check[i] = LessThan(4);
    lt_range_check[i].in[0] <== guess[i];
    lt_range_check[i].in[1] <== 10;
    // Force output to be 1, constraint fails if guess[i] >= 10
    lt_range_check[i].out === 1;
}

// Calculate bulls (A)
// First, initialize components
for (var i = 0; i < 4; i++) {
    eq_bulls[i] = IsEqual();
    eq_bulls[i].in[0] <== guess[i];
    eq_bulls[i].in[1] <== secret[i];
}
// Now, define bulls as the sum
bulls <== eq_bulls[0].out + eq_bulls[1].out + eq_bulls[2].out + eq_bulls[3].out;

// Calculate totalMatches
// First, set up all components and their inputs in the loop
for (var d = 0; d < 10; d++) {
    // Inner loop: initialize eqG and eqS components
    for (var i = 0; i < 4; i++) {
        eqG_components[d][i] = IsEqual();
        eqG_components[d][i].in[0] <== guess[i];
        eqG_components[d][i].in[1] <== d;

        eqS_components[d][i] = IsEqual();
        eqS_components[d][i].in[0] <== secret[i];
        eqS_components[d][i].in[1] <== d;
    }
    // After the inner loop, define countG_arr[d] and countS_arr[d]
    countG_arr[d] <== eqG_components[d][0].out + eqG_components[d][1].out + eqG_components[d][2].out + eqG_components[d][3].out;
    countS_arr[d] <== eqS_components[d][0].out + eqS_components[d][1].out + eqS_components[d][2].out + eqS_components[d][3].out;

    // Initialize Min component and connect inputs
    min_components[d] = Min();
    min_components[d].a <== countG_arr[d];
    min_components[d].b <== countS_arr[d];
}

// After all 'd' loops are completed, define totalMatches
// Here we need to sum the outputs of 10 min_components
totalMatches <== min_components[0].out +
                 min_components[1].out +
                 min_components[2].out +
                 min_components[3].out +
                 min_components[4].out +
                 min_components[5].out +
                 min_components[6].out +
                 min_components[7].out +
                 min_components[8].out +
                 min_components[9].out;

cows <== totalMatches - bulls;

// Calculate isCorrect
component eq4 = IsEqual();
eq4.in[0] <== bulls;
eq4.in[1] <== 4;
isCorrect <== eq4.out;

}

component main = Reveal1A2B();
