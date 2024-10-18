module rw_instr_mem(
  input  logic        clk_i,
  input  logic [31:0] read_addr_i,
  output logic [31:0] read_data_o,

  input  logic [31:0] write_addr_i,
  input  logic [31:0] write_data_i,
  input  logic        write_enable_i
);

localparam MEM_SIZE_BYTES = 32'h10000;
localparam MEM_SIZE_WORDS = MEM_SIZE_BYTES / 4;
localparam WORDS_WIDTH = $clog2(MEM_SIZE_WORDS);
logic [31:0] memory [0:MEM_SIZE_WORDS];
localparam MEMBITES = $clog2(MEM_SIZE_BYTES);

initial begin
    $readmemh("coremark_instr.mem", memory);
end

assign read_data_o = memory[read_addr_i[MEMBITES:2]];

always_ff @(posedge clk_i) begin
    if(write_enable_i) begin
        memory[write_addr_i[MEMBITES:2]] <= write_data_i;
    end
end
endmodule