`timescale 1ns / 1ps

module carryLookaheadAdder(
    input[3:0] A,B,
    input Cin,
    output S3,
    output S2,
    output S1,
    output S0,
    output Co
    );
    
    assign {A3,A2,A1,A0} = A;
    assign {B3,B2,B1,B0} = B;
    
    assign G3 = A3&B3;
    assign G2 = A2&B2;
    assign G1 = A1&B1;
    assign G0 = A0&B0;
    
    assign P3 = A3^B3;
    assign P2 = A2^B2;
    assign P1 = A1^B1;
    assign P0 = A0^B0;
    
    assign C3 = G3 + P3&G2 + P3&P2&G1 + P3&P2&P1&G0 + P3&P2&P1&P0&Cin;
    assign C2 = G2 + P2&G1 + P2&P1&G0 + P2&P1&P0&Cin;
    assign C1 = G1 + P1&G0 + P1&P0&Cin;
    assign C0 = G0 + P0&Cin;
    
    assign S3 = P3 ^ C2;
    assign S2 = P2 ^ C1;
    assign S1 = P1 ^ C0;
    assign S0 = P0 ^ Cin;
    assign Co = C3;
    
endmodule
