module riscv_unit(
    input  logic        clk_i,
    input  logic        resetn_i,
     

    input  logic        rx_i,       
    output logic        tx_o,       
    
    output logic [31:0] instr_addr_o,
    output logic [31:0] core_rd_o   
);


logic sysclk, rst;
//sys_clk_rst_gen divider(.ex_clk_i(clk_i),.ex_areset_n_i(resetn_i),.div_i(5),.sys_clk_o(sysclk), .sys_reset_o(rst));
assign sysclk = clk_i;
assign rst = ~resetn_i;
logic [31:0] instr_addr;

/*(* mark_debug = "true" *)*/ logic [31:0] instr;
/*(* mark_debug = "true" *)*/ logic core_reset;

logic [31:0] core_addr, core_wd, core_rd;
logic [2:0]  core_size;
logic core_stall, core_req, core_we;

logic mem_req;
logic [31:0] mem_addr,  mem_wd,  mem_rd;
logic [3:0]  mem_be;
logic mem_we, mem_ready;

logic lsu_mem_req;
logic [31:0] lsu_mem_addr,  lsu_mem_wd;
logic [3:0]  lsu_mem_be;
logic lsu_mem_we;

logic [15:0] irq_ret, irq_req;
assign irq_req[15:2] = 14'd0;

logic [255:0] oh_enc;

assign oh_enc = 255'd1 << mem_addr[31:24];

//BLUSTER
logic [31:0] blu_instr_addr, blu_instr_wdata;
logic        blu_instr_we;
logic [31:0] blu_data_addr, blu_data_wdata;
logic        blu_data_we;

assign instr_addr_o = instr_addr;
assign core_rd_o    = instr;

instr_mem instr_memory(
    .addr_i(instr_addr),
    .read_data_o(instr)
);

assign core_reset = rst;

riscv_core core(
    .clk_i(sysclk),
    .rst_i(core_reset),
    .instr_addr_o(instr_addr),
    .instr_i(instr),
    .mem_size_o(core_size),
    .mem_addr_o(core_addr),
    .mem_wd_o(core_wd),
    .mem_req_o(core_req),
    .mem_we_o(core_we),
    .mem_rd_i(core_rd),
    .stall_i(core_stall),
    .irq_ret_o(irq_ret),
    .irq_req_i(irq_req)
);

riscv_lsu lsu(
    .clk_i(sysclk),
    .rst_i(rst),

    .core_stall_o(core_stall),
    .core_req_i(core_req),
    .core_we_i(core_we),
    .core_size_i(core_size),
    .core_wd_i(core_wd),
    .core_addr_i(core_addr),
    .core_rd_o(core_rd),
    
    .mem_req_o(lsu_mem_req),
    .mem_we_o(lsu_mem_we),
    .mem_be_o(lsu_mem_be),
    .mem_wd_o(lsu_mem_wd),
    .mem_addr_o(lsu_mem_addr),
    .mem_rd_i(mem_rd),
    .mem_ready_i(mem_ready)
);

assign mem_req = core_reset ? blu_data_we : lsu_mem_req;
assign mem_we = core_reset ? blu_data_we : lsu_mem_we;
assign mem_be = core_reset ? 4'hf : lsu_mem_be;
assign mem_wd = core_reset ? blu_data_wdata : lsu_mem_wd;
assign mem_addr = core_reset ? blu_data_addr : lsu_mem_addr;

//case mem_rd

logic [31:0] data_mem_rd, ps2_mem_rd, vga_mem_rd,uart_rx_mem_rd, uart_tx_mem_rd, timer_mem_rd;

always_comb begin
    mem_rd = 32'd0;
    case(oh_enc[8:0])
        9'b00000_0001: mem_rd = data_mem_rd;
        9'b00000_1000: mem_rd = ps2_mem_rd;
        9'b00010_0000: mem_rd = uart_rx_mem_rd;
        9'b00100_0000: mem_rd = uart_tx_mem_rd;
        9'b01000_0000: mem_rd = vga_mem_rd;
        9'b10000_0000: mem_rd = timer_mem_rd;
    endcase
end
    

//data mem
ext_mem em(
    .clk_i(sysclk),
    .mem_req_i(mem_req & oh_enc[0]),
    .byte_enable_i(mem_be),
    .write_enable_i(mem_we & oh_enc[0]),
    .write_data_i(mem_wd),
    .addr_i({8'd0,mem_addr[23:0]}),
    .read_data_o(data_mem_rd),
    .ready_o(mem_ready)
);

//uart_rx 
uart_rx_sb_ctrl uart_rx(
    .clk_i(sysclk),
    .rst_i(rst),
    .addr_i({8'd0,mem_addr[23:0]}),             
    .req_i(mem_req & oh_enc[5]),              
    .write_data_i(mem_wd),       
    .write_enable_i(mem_we & oh_enc[5]),     
    .read_data_o(uart_rx_mem_rd),
    .interrupt_request_o(irq_req[1]),
    .interrupt_return_i(irq_ret[1]),
    .rx_i(rx_i)
);

//uart_tx 
uart_tx_sb_ctrl uart_tx(
    .clk_i(sysclk),
    .rst_i(rst),
    .addr_i({8'd0,mem_addr[23:0]}),             
    .req_i(mem_req & oh_enc[6]),              
    .write_data_i(mem_wd),       
    .write_enable_i(mem_we & oh_enc[6]),     
    .read_data_o(uart_tx_mem_rd),
    .tx_o(tx_o)
);

//timer 
timer_sb_ctrl timer(
    .clk_i(sysclk),
    .rst_i(rst),
    .addr_i({8'd0,mem_addr[23:0]}),             
    .req_i(mem_req & oh_enc[8]),              
    .write_data_i(mem_wd),       
    .write_enable_i(mem_we & oh_enc[8]),     
    .read_data_o(timer_mem_rd),
    .ready_o(),
    .interrupt_request_o(irq_req[0])
);

endmodule
