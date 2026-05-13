`timescale 1ns / 1ps

module fulladder4(   input  logic   [3:0]      a_i,
                     input  logic   [3:0]      b_i,
                     input  logic          carry_i,
                     
                     output logic          carry_o,
                     output logic   [3:0]    sum_o                                    
);

logic carry0to1;

logic carry1to2;

logic carry2to3;

fulladder adder0(
                  .a_i           (    a_i[0] ),
                  .b_i           (    b_i[0] ),
                  .carry_i       ( carry_i   ),
                  .carry_o       ( carry0to1 ),
                  .sum_o         (  sum_o[0] )
);

fulladder adder1(
                  .a_i           (    a_i[1] ),
                  .b_i           (    b_i[1] ),
                  .carry_i       ( carry0to1 ),
                  .carry_o       ( carry1to2 ),
                  .sum_o         (  sum_o[1] )
);

fulladder adder2(
                  .a_i           (    a_i[2] ),
                  .b_i           (    b_i[2] ),
                  .carry_i       ( carry1to2 ),
                  .carry_o       ( carry2to3 ),
                  .sum_o         (  sum_o[2] )
);

fulladder adder3(
                  .a_i           (    a_i[3] ),
                  .b_i           (    b_i[3] ),
                  .carry_i       ( carry2to3 ),
                  .carry_o       ( carry_o   ),
                  .sum_o         (  sum_o[3] )
);

endmodule

