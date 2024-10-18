`timescale 1ns / 1ps

module csr_controller(
                           input  logic                   clk_i,
                           input  logic                   rst_i,
                           input  logic                  trap_i,
                           
                           input  logic [2:0]          opcode_i,
                           
                           input  logic [11:0]           addr_i,
                           input  logic [31:0]             pc_i,
                           input  logic [31:0]         mcause_i,
                           input  logic [31:0]       rs1_data_i,
                           input  logic [31:0]       imm_data_i,
                           input  logic           write_enable_i,
                           
                           output logic [31:0]      read_data_o,
                           output logic [31:0]            mie_o,
                           output logic [31:0]           mepc_o,
                           output logic [31:0]          mtvec_o
);

import csr_pkg::*;

logic [31:0] result_mux;
logic [4:0]  enable;
logic [31:0] reg1;
logic [31:0] reg2;

always_comb
  begin
    case ( opcode_i )
      CSR_RW  : result_mux =   rs1_data_i;
      CSR_RS  : result_mux =   rs1_data_i | read_data_o;
      CSR_RC  : result_mux =  ~rs1_data_i & read_data_o;
      CSR_RWI : result_mux =   imm_data_i;
      CSR_RSI : result_mux =   imm_data_i | read_data_o;
      CSR_RCI : result_mux =    ~imm_data_i & read_data_o;
      default : result_mux =    result_mux;
    endcase
  end
  
  
always_comb
  begin
    case ( addr_i )
      MIE_ADDR      :  enable =  { 4'h0   , write_enable_i};
      MTVEC_ADDR    :  enable =  { 3'b000 , write_enable_i , 1'b0};
      MSCRATCH_ADDR :  enable  = { 2'b00  , write_enable_i , 2'b00};
      MEPC_ADDR     :  enable  = { 1'b0   , write_enable_i , 3'b000};
      MCAUSE_ADDR   :  enable  = { write_enable_i , 4'h0};
      default:         enable = 5'b00000;
    endcase
  end
 
always_ff @( posedge clk_i or posedge rst_i )
  if ( rst_i )
    mie_o <= 'd0;
  else
    if ( enable[0] )
      mie_o <= result_mux;
    else
      mie_o <= mie_o;
      
always_ff @( posedge clk_i or posedge rst_i )
  if ( rst_i )
    mtvec_o <= 'd0;
  else
    if ( enable[1] )
      mtvec_o <= result_mux;
      
always_ff @( posedge clk_i or posedge rst_i )
  if ( rst_i )
    reg1 <= 'd0;
  else
    if ( enable[2] )
      reg1 <= result_mux;
      
always_ff @( posedge clk_i or posedge rst_i )
  if ( rst_i )
    mepc_o <= 'd0;
  else
    if ( enable[3] | trap_i)
      mepc_o <= trap_i ? pc_i :result_mux;
      
always_ff @( posedge clk_i or posedge rst_i )
  if ( rst_i )
    reg2 <= 'd0;
  else
    if ( enable[4] | trap_i)
      reg2 <= trap_i ? mcause_i :result_mux;
      
 always_comb
   begin
     case ( addr_i )
       MIE_ADDR      :  read_data_o = mie_o;
       MTVEC_ADDR    :  read_data_o = mtvec_o;
       MSCRATCH_ADDR :  read_data_o = reg1;
       MEPC_ADDR     :  read_data_o = mepc_o;
       MCAUSE_ADDR   :  read_data_o = reg2;
       default       :  read_data_o = read_data_o;
     endcase
   end
endmodule
