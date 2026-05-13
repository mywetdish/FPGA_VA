`timescale 1ns / 1ps


 module riscv_core (

                           input  logic        clk_i,
                           input  logic        rst_i,

                           input  logic        stall_i,
                           input  logic [15:0] irq_req_i,
                           input  logic [31:0] instr_i,
                           input  logic [31:0] mem_rd_i,

                           output logic [31:0] instr_addr_o,
                           output logic [31:0] mem_addr_o,
                           output logic [ 2:0] mem_size_o,
                           output logic        mem_req_o,
                           output logic        mem_we_o,
                           output logic [31:0] mem_wd_o,
                           output logic [15:0] irq_ret_o
);

logic [1:0]   a_sel_o_temp;
logic [2:0]   b_sel_o_temp;
logic [5:0]   alu_op_temp;
logic         grp_we_o_temp;
logic [1:0]   wb_sel_o_temp;
logic         branch_o_temp;  
logic            jal_o_temp; 
logic           jalr_o_temp;
logic       alu_flag_o_temp;

logic [31:0]  b_sum_temp;


logic [4:0]  read_addr1_o_temp;
logic [4:0]  read_addr2_o_temp;
logic [4:0]  write_addr_temp;

logic [31:0] read_data1_temp;
logic [31:0] read_data2_temp;
logic [31:0] write_data_temp;
logic [31:0] costant_temp;

logic [31:0]  program_counter;
logic [31:0]  program_counter_data;
logic [31:0]  program_counter_data_temp;
logic [31:0]  program_counter_wire1;
logic [31:0]  program_counter_wire2;
logic [31:0]  result_sum;

logic [4:0] read_addr1;
logic [4:0] read_addr2;
logic [4:0]  write_addr;

logic [31:0] read_data1;
logic [31:0] read_data2;
logic [31:0] write_data;

logic [31:0] a_i_temp;
logic [31:0] b_i_temp;

logic [11:0]  imm_i;
logic [11:0]  imm_s;
logic [12:0]  imm_b;
logic [20:0]  imm_j;
logic [4:0]   imm_z;

logic [31:0]  imm_i_data;
logic [31:0]  imm_u_data;
logic [31:0]  imm_s_data;
logic [31:0]  imm_b_data;
logic [31:0]  imm_j_data;
logic [31:0]  imm_z_data;

logic [31:0] write_data_mux;

logic illegal_instr;    //decod wires
logic mret_o_temp;
logic [2:0] csr_op_o_temp;
logic csr_we_o_temp;
logic mem_req_o_temp;
logic mem_we_o_temp;

logic [31:0] mie_temp;
logic [31:0] mtvec_temp;
logic [31:0] mepc_temp;
logic [31:0] csr_wd_o_temp;  // csr wires
logic trap;

logic irq_o_temp;      // interrupt wires
logic [31:0] irq_cause_o_temp;




decoder_riscv  decod (
                        .fetched_instr_i       ( instr_i       ),
                        .a_sel_o               ( a_sel_o_temp  ),                    
                        .b_sel_o               ( b_sel_o_temp  ),
                        .alu_op_o              ( alu_op_temp   ),
                        .mem_req_o             ( mem_req_o_temp),
                        .mem_we_o              ( mem_we_o_temp ),
                        .mem_size_o            ( mem_size_o    ),
                        .gpr_we_o              ( grp_we_o_temp ),        
                        .wb_sel_o              ( wb_sel_o_temp ),
                        .branch_o              ( branch_o_temp ),   
                        .jal_o                 ( jal_o_temp    ),
                        .jalr_o                ( jalr_o_temp   ),
                        .illegal_instr_o       ( illegal_instr ),
                        .mret_o                ( mret_o_temp   ),
                        .csr_op_o              ( csr_op_o_temp ),
                        .csr_we_o              ( csr_we_o_temp )
);

alu_riscv alutorf(
                      .a_i            ( a_i_temp            ),
                      .b_i            ( b_i_temp            ),
                      .result_o       ( write_data_mux      ),
                      .alu_op_i       ( alu_op_temp         ),
                      .flag_o         ( alu_flag_o_temp     )
);

rf_riscv rftoPC (
                      .clk_i         ( clk_i             ),
                      .read_data1_o  ( read_data1_temp ),
                      .read_data2_o  ( read_data2_temp ),
                      .write_data_i  ( write_data_temp   ),
                      .read_addr1_i  ( read_addr1        ),
                      .read_addr2_i  ( read_addr2        ),
                      .write_addr_i  ( write_addr        ),
                      .write_enable_i( (~(stall_i | trap  ) & grp_we_o_temp))
);   

fulladder32 addertoPC (
                         .a_i      (  program_counter           ),
                         .b_i      (  b_sum_temp                ),
                         .carry_i  (  1'b0                      ),
                         .sum_o    (  program_counter_data_temp )
);

csr_controller csr (
                              .clk_i           ( clk_i          ),
                              .rst_i           ( rst_i          ),
                              .trap_i          ( trap           ),
                              .opcode_i        ( csr_op_o_temp  ),
                              .addr_i          ( instr_i[31:20] ),
                              .pc_i            ( program_counter),
                              .mcause_i        ( illegal_instr ? 32'h0000_0002 :  irq_cause_o_temp),
                              .rs1_data_i      ( read_data1_temp),
                              .imm_data_i      ( imm_z_data     ),
                              .write_enable_i  ( csr_we_o_temp  ),
                              .read_data_o     ( csr_wd_o_temp  ),
                              .mie_o           ( mie_temp       ),
                              .mepc_o          ( mepc_temp      ),
                              .mtvec_o         ( mtvec_temp     )
);

interrupt_controller intr ( 
                              .clk_i           ( clk_i           ),
                              .rst_i           ( rst_i           ),
                              .exception_i     ( illegal_instr   ),
                              .irq_req_i       ( irq_req_i       ),
                              .mie_i           ( mie_temp[15:0]     ),
                              .mret_i          ( mret_o_temp     ),
                              .irq_ret_o       ( irq_ret_o       ),
                              .irq_cause_o     ( irq_cause_o_temp),
                              .irq_o           ( irq_o_temp      )
);





assign read_addr1 = instr_i [19:15];
assign read_addr2 = instr_i [24:20];
assign write_addr = instr_i [11:7];

assign imm_i = instr_i [31:20];
assign imm_u_data = {instr_i [31:12] , 12'h000};
assign imm_s = {instr_i [31:25], instr_i [11:7]};
assign imm_b = {instr_i [31],instr_i [7], instr_i [30:25], instr_i [11:8] , 1'b0};
assign imm_j = {instr_i [31], instr_i [19:12], instr_i [20], instr_i [30:21] , 1'b0};
assign imm_z = instr_i[19:15];

assign imm_z_data =  { {27{imm_z[4]}} , imm_z[4:0]};

always_comb
  begin
    if ( imm_i[11] )
      imm_i_data = { 20'hFFFFF , imm_i };
    else
      imm_i_data = { 20'h00000 , imm_i };
  end
  
  always_comb
  begin
    if ( imm_s[11] )
      imm_s_data = { 20'hFFFFF , imm_s };
    else
      imm_s_data = { 20'h00000 , imm_s };
  end
  always_comb
  begin
    if ( imm_b[12] )
      imm_b_data = { 20'hFFFFF , imm_b };
    else
      imm_b_data = { 20'h00000 , imm_b };
  end
  
  always_comb
  begin
    if ( imm_j[20] )
      imm_j_data = { 20'hFFFFF , imm_j };
    else
      imm_j_data = { 20'h00000 , imm_j };
  end
  
  
  always_comb
  begin
    if ( ~branch_o_temp )
      costant_temp =  imm_j_data;     //
    else
      costant_temp =  imm_b_data; 
   end
   
   
   always_comb 
     begin
       if( (alu_flag_o_temp & branch_o_temp) | jal_o_temp)
         b_sum_temp = costant_temp;
       else
         b_sum_temp = 'd4;
     end
     
   always_comb
     begin
       if ( jalr_o_temp )
         program_counter_data  = { result_sum [31:1] ,1'b0};
       else
         program_counter_data  = program_counter_data_temp;
     end
   always_comb
     begin
       if ( trap )
         program_counter_wire1  = mtvec_temp;
       else
         program_counter_wire1  = program_counter_data;
     end
   always_comb
     begin
       if ( mret_o_temp )
         program_counter_wire2  = mepc_temp;
       else
         program_counter_wire2  = program_counter_wire1;
     end
       
  always_comb
     begin
       case ( a_sel_o_temp ) 
         2'b0:    a_i_temp =  read_data1;
         2'b1:    a_i_temp =  program_counter;
         2'b10:   a_i_temp =  '0;
       endcase
     end       
       
  always_comb
     begin
       case ( b_sel_o_temp ) 
         3'd0:    b_i_temp =  read_data2;
         3'd1:    b_i_temp =  imm_i_data;
         3'd2:    b_i_temp =  imm_u_data;
         3'd3:    b_i_temp =  imm_s_data;
         3'd4:    b_i_temp =  'd4;
       endcase
     end 
  always_comb
    begin
      case ( wb_sel_o_temp )
        2'b00:  write_data_temp = write_data_mux;
        2'b01:  write_data_temp = mem_rd_i;
        2'b10:  write_data_temp = csr_wd_o_temp;
      endcase
    end
            
  
always_ff @ ( posedge clk_i  or posedge rst_i ) begin
  if ( rst_i )
    program_counter <= 'd0;
  else
    if ( !stall_i | trap)
      program_counter <= program_counter_wire2;
    else
      program_counter <= program_counter;
 end

assign instr_addr_o = program_counter;

assign read_data1 = read_data1_temp;
assign read_data2 = read_data2_temp;

assign result_sum = read_data1 + imm_i_data;


assign mem_wd_o = read_data2;
assign mem_addr_o = write_data_mux;

assign trap = irq_o_temp | illegal_instr;

assign mem_req_o = mem_req_o_temp & ~trap;

assign mem_we_o = mem_we_o_temp & ~ trap;


endmodule
