module ext_mem(
    input  logic        clk_i,
    input  logic        mem_req_i,
    input  logic        write_enable_i,
    input  logic [3:0]  byte_enable_i,
    input  logic [31:0] addr_i,
    input  logic [31:0] write_data_i,
    output logic [31:0] read_data_o,
    output logic        ready_o
);

logic [31:0] memory [0:4095];

assign ready_o = 1'b1;

initial begin
  $readmemh("coremark_data.mem" , memory);
end

always_ff @(posedge clk_i) begin
    if(mem_req_i & ~write_enable_i)
        read_data_o <= memory[addr_i[13:2]];
    else
        read_data_o <= read_data_o;
end

always_ff @(posedge clk_i) begin
    if(mem_req_i & write_enable_i) begin
        memory[addr_i[13:2]][7:0]   <= (byte_enable_i[0]) ? write_data_i[7:0]   : memory[addr_i[13:2]][7:0];
        memory[addr_i[13:2]][15:8]  <= (byte_enable_i[1]) ? write_data_i[15:8]  : memory[addr_i[13:2]][15:8];
        memory[addr_i[13:2]][23:16] <= (byte_enable_i[2]) ? write_data_i[23:16] : memory[addr_i[13:2]][23:16];
        memory[addr_i[13:2]][31:24] <= (byte_enable_i[3]) ? write_data_i[31:24] : memory[addr_i[13:2]][31:24];
    end
end


endmodule