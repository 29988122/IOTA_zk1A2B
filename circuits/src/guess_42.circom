pragma circom 2.1.5;

template Commit42() {
    signal input x;
    signal output out;

    // constraint：x is 42
    x === 42;

    //  x 
    out <== x;
}

// Instantiate main component
component main = Commit42();