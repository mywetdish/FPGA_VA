`timescale 1ns / 1ps

module instr_mem (
                     input  logic [31:0] addr_i,
                     output logic [31:0] read_data_o
);

logic [31:0] memory [16384];

initial begin
 $readmemh("coremark_instr.mem",memory);
 end

assign read_data_o = memory[addr_i[15:2]];

endmodule
