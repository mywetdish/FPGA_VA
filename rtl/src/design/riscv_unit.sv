`timescale 1ns / 1ps



module riscv_unit(
                     input logic clk_i,
                     input logic rst_i,
                     
                     input logic irq_req_i,
                     
                     output logic [31:0] instr_addr_o,
                     output logic [31:0] core_rd_o
    );
    
    
logic [31:0] instr_addr_temp;            //instr_mem to core wires
logic [31:0] instr_temp;


logic mem_req_o_temp;
logic mem_we_o_temp;
logic [2:0] mem_size_o_temp;
logic [31:0] mem_addr_o_temp;
logic [31:0] mem_wd_o_temp;            // core to lsu wires
logic [31:0] mem_rd_i_temp;
logic stall_i_temp;


logic mem_req_i_temp;
logic we_i_temp;
logic [3:0 ]mem_be_o_temp;
logic [31:0] addr_i_temp;
logic [31:0] wd_o_temp;
logic [31:0] read_data_temp;
logic mem_ready_i_temp;

logic irq_req;
logic irq_ret;

assign irq_req = irq_req_i;


assign instr_addr_o = instr_addr_temp;
assign core_rd_o = instr_temp;    


instr_mem mem ( 
               .addr_i                    ( instr_addr_temp   ),
               .read_data_o               ( instr_temp        ) 
);            

ext_mem ex_mem   (
                      .clk_i              (   clk_i           ),
                      .mem_req_i          (   mem_req_i_temp  ),
                      .write_enable_i     (   we_i_temp       ),
                      .byte_enable_i      (   mem_be_o_temp   ),
                      .write_data_i       (   wd_o_temp       ),
                      .ready_o            (   mem_ready_i_temp),
                      .addr_i             (   addr_i_temp     ),                 
                      .read_data_o        (   read_data_temp  )
                          
);

riscv_core core (
                  .clk_i                  ( clk_i             ),
                  .rst_i                  ( rst_i             ),
                  .stall_i                ( stall_i_temp      ),
                  .instr_i                ( instr_temp        ),       
                  .mem_rd_i               ( mem_rd_i_temp     ),
                  .instr_addr_o           ( instr_addr_temp   ),
                  .mem_size_o             ( mem_size_o_temp   ),
                  .mem_addr_o             ( mem_addr_o_temp   ),
                  .mem_req_o              ( mem_req_o_temp    ),
                  .mem_we_o               ( mem_we_o_temp     ), 
                  .mem_wd_o               ( mem_wd_o_temp     ),
                  .irq_req_i              ( irq_req           ),
                  .irq_ret_o              ( irq_ret           )
 );  
 
 
 riscv_lsu lsu (
                  .clk_i                  ( clk_i              ),
                  .rst_i                  ( rst_i              ),
                     
                  .core_req_i             ( mem_req_o_temp     ),
                  .core_we_i              ( mem_we_o_temp      ),
                  .core_size_i            ( mem_size_o_temp    ),
                  .core_addr_i            ( mem_addr_o_temp    ),   
                  .core_wd_i              ( mem_wd_o_temp      ),
                  .core_rd_o              ( mem_rd_i_temp      ),
                  .core_stall_o           ( stall_i_temp       ),
               
                  .mem_req_o              ( mem_req_i_temp     ),
                  .mem_we_o               ( we_i_temp          ),          
                  .mem_be_o               ( mem_be_o_temp      ),
                  .mem_addr_o             ( addr_i_temp        ),
                  .mem_wd_o               ( wd_o_temp          ),
                  .mem_rd_i               ( read_data_temp     ),
                  .mem_ready_i            ( mem_ready_i_temp   )
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
    .interrupt_request_o(irq_req[0]),
    .interrupt_return_i(irq_ret[0]),
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
    .interrupt_request_o(irq_req[1])
);
 
 

endmodule
