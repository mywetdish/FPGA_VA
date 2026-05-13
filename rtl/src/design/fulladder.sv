`timescale 1ns / 1ps


module fulladder( input   logic          a_i,
                  input   logic          b_i,
                  input   logic      carry_i,
                  
                  output  logic      carry_o,
                  output  logic        sum_o
);
    
assign sum_o = carry_i ^ ( a_i ^ b_i);

assign carry_o = ( b_i & carry_i) | ( ( a_i & carry_i) | ( a_i & b_i));

endmodule
