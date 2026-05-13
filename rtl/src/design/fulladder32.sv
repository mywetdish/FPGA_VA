`timescale 1ns / 1ps


module fulladder32(   input  logic   [31:0]      a_i,
                      input  logic   [31:0]      b_i,
                      input  logic           carry_i,
                     
                      output logic           carry_o,
                      output logic   [31:0]    sum_o                                   
);

logic carry1to0;

logic carry1to2;

logic carry2to3;

logic carry3to4;

logic carry4to5;

logic carry5to6;

logic carry6to7;


fulladder4 adder0(
                  .a_i           (    a_i[3:0] ),
                  .b_i           (    b_i[3:0] ),
                  .carry_i       ( carry_i     ),
                  .carry_o       ( carry0to1   ),
                  .sum_o         (  sum_o[3:0] )
);

fulladder4 adder1(
                  .a_i           (    a_i[7:4] ),
                  .b_i           (    b_i[7:4] ),
                  .carry_i       ( carry0to1   ),
                  .carry_o       ( carry1to2   ),
                  .sum_o         (  sum_o[7:4] )
);

fulladder4 adder2(
                  .a_i           (    a_i[11:8] ),
                  .b_i           (    b_i[11:8] ),
                  .carry_i       (   carry1to2  ),
                  .carry_o       ( carry2to3    ),
                  .sum_o         (  sum_o[11:8] )
);

fulladder4 adder3(
                  .a_i           (    a_i[15:12] ),
                  .b_i           (    b_i[15:12]  ),
                  .carry_i       (   carry2to3   ),
                  .carry_o       ( carry3to4     ),
                  .sum_o         (  sum_o[15:12]  )
);

fulladder4 adder4(
                  .a_i           (    a_i[19:16] ),
                  .b_i           (    b_i[19:16] ),
                  .carry_i       (   carry3to4   ),
                  .carry_o       ( carry4to5     ),
                  .sum_o         (  sum_o[19:16] )
);

fulladder4 adder5(
                  .a_i           (    a_i[23:20] ),
                  .b_i           (    b_i[23:20] ),
                  .carry_i       (   carry4to5   ),
                  .carry_o       ( carry5to6     ),
                  .sum_o         (  sum_o[23:20] )
);

fulladder4 adder6(
                  .a_i           (    a_i[27:24] ),
                  .b_i           (    b_i[27:24] ),
                  .carry_i       (   carry5to6   ),
                  .carry_o       ( carry6to7    ),
                  .sum_o         (  sum_o[27:24] )
);

fulladder4 adder7(
                  .a_i           (    a_i[31:28]  ),
                  .b_i           (    b_i[31:28]  ),
                  .carry_i       (   carry6to7   ),
                  .carry_o       (   carry_o      ),
                  .sum_o         (   sum_o[31:28] )
);

endmodule