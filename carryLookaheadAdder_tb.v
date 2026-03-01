`timescale 1ns / 1ps

module carryLookaheadAdder_tb();
    
    reg[3:0] A,B;
    reg Cin;
    
    wire S3,S2,S1,S0,Co;
    
    carryLookaheadAdder uut(A,B,Cin,S3,S2,S1,S0,Co);
    integer k,j;
    
    initial begin
        for(k=0;k<16;k=k+1)begin
            for(j=0;j<16;j=j+1)begin
                A = k;
                B = j;
                Cin = 1'b0;
                #10 $display("A = %b, B=%b, Cin = 0, S = %b, Co = %b", A,B,{S3,S2,S1,S0},Co);
            end
        end
    end
    
endmodule
