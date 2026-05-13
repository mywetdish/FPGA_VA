`timescale 1ns / 1ps

module decoder_riscv(
                         input  logic [31:0]  fetched_instr_i,
                         output logic [1:0]   a_sel_o,
                         output logic [2:0]   b_sel_o,
                         output logic [4:0]   alu_op_o,
                         output logic [2:0]   csr_op_o,
                         output logic         csr_we_o,
                         output logic         mem_req_o,
                         output logic         mem_we_o,
                         output logic [2:0]   mem_size_o,
                         output logic         gpr_we_o,
                         output logic [1:0]   wb_sel_o,        
                         output logic         illegal_instr_o,
                         output logic         branch_o,
                         output logic         jal_o,
                         output logic         jalr_o,
                         output logic         mret_o
);
  import riscv_pkg::*;
  
logic [6:0] funct7;
logic [2:0] funct3;
logic [6:0] opcode;
logic [4:0] rd;
logic [4:0] rs1;
logic [4:0] rs2;

assign opcode = fetched_instr_i [6:0];

assign funct3 = fetched_instr_i [14:12];

assign funct7 = fetched_instr_i [31:25];

assign rd     = fetched_instr_i [11:7];

assign rs1    = fetched_instr_i [19:15];

assign rs2    =  fetched_instr_i [24:20];

always_comb begin
    illegal_instr_o = 1'b0;
    branch_o        = 1'b0;
    jal_o           = 1'b0;
    jalr_o          = 1'b0;
    mret_o          = 1'b0;
    gpr_we_o        = 1'b0;
    csr_we_o        = 1'b0;
    mem_we_o        = 1'b0;
    mem_req_o       = 1'b0;
    wb_sel_o        = 2'b0;
    case( opcode )
      7'b0110011:         case ( funct7 )             
                          7'h00:                     case ( funct3 )
                                                       3'h0:     begin          alu_op_o   = ALU_ADD; 
                                                                                a_sel_o    = 2'b0;
                                                                                b_sel_o    = 3'b0;
                                                                                gpr_we_o   = 1'b1; 
                                                                                wb_sel_o   = 2'b0;
                                                                                                                                                                                                                                                
                                                                 end
                                                       3'h4:     begin          alu_op_o   = ALU_XOR;
                                                                                a_sel_o    = 2'b0;
                                                                                b_sel_o    = 3'b0;
                                                                                gpr_we_o   = 1'b1; 
                                                                                wb_sel_o   = 2'b0; 
                                                                                
                                                                 end
                                                       3'h6:     begin          alu_op_o   = ALU_OR;
                                                                                a_sel_o    = 2'b0;
                                                                                b_sel_o    = 3'b0;
                                                                                gpr_we_o   = 1'b1; 
                                                                                wb_sel_o   = 2'b0; 
                                                                               
                                                                 end
                                                       3'h7:     begin          alu_op_o   = ALU_AND;
                                                                                a_sel_o    = 2'b0;
                                                                                b_sel_o    = 3'b0;
                                                                                gpr_we_o   = 1'b1; 
                                                                                wb_sel_o   = 2'b0; 
                                                                                
                                                                 end
                                                       3'h1:     begin          alu_op_o   = ALU_SLL;
                                                                                a_sel_o    = 2'b0;
                                                                                b_sel_o    = 3'b0;
                                                                                gpr_we_o   = 1'b1; 
                                                                                wb_sel_o   = 2'b0; 
                                                                                
                                                                 end
                                                       3'h5:     begin          alu_op_o   = ALU_SRL;
                                                                                a_sel_o    = 2'b0;
                                                                                b_sel_o    = 2'b0;
                                                                                gpr_we_o   = 1'b1; 
                                                                                wb_sel_o   = 2'b0; 
                                                                                
                                                                 end
                                                       3'h2:     begin          alu_op_o   = ALU_SLTS;
                                                                                a_sel_o    = 2'b0;
                                                                                b_sel_o    = 3'b0;
                                                                                gpr_we_o   = 1'b1; 
                                                                                wb_sel_o   = 2'b0; 
                                                                                
                                                                 end
                                                       3'h3:     begin          alu_op_o   = ALU_SLTU;
                                                                                a_sel_o    = 2'b0;
                                                                                b_sel_o    = 3'b0;
                                                                                gpr_we_o   = 1'b1; 
                                                                                wb_sel_o   = 2'b0; 
                                                                               
                                                                 end
                                                       default:                 illegal_instr_o = 1'b1;
                                                                 
                                                       endcase
                          7'h20:                     case ( funct3 )
                                                     3'h0:       begin         alu_op_o   = ALU_SUB;
                                                                               a_sel_o    = 2'b0;
                                                                               b_sel_o    = 3'b0;
                                                                               gpr_we_o   = 1'b1; 
                                                                               wb_sel_o   = 2'b0; 
                                                                              
                                                                 end
                                                     3'h5:       begin         alu_op_o   =  ALU_SRA;
                                                                               a_sel_o    = 2'b0;
                                                                               b_sel_o    = 3'b0;
                                                                               gpr_we_o   = 1'b1; 
                                                                               wb_sel_o   = 2'b0; 
                                                                             
                                                                 end
                                                     default:                 illegal_instr_o = 1'b1;  
                                                       
                                                     endcase
                         default:                 illegal_instr_o = 1'b1;
                          endcase
                          
      7'b0010011:       case( funct3 )
                        3'h0:     begin           alu_op_o   = ALU_ADD;
                                                  a_sel_o    = 2'b0;
                                                  b_sel_o    = 3'b1;
                                                  gpr_we_o   = 1'b1;
                                                  wb_sel_o   = 2'b0; 
                                  end
                       3'h4:      begin           alu_op_o   = ALU_XOR;
                                                  a_sel_o    = 2'b0;
                                                  b_sel_o    = 3'b1;
                                                  gpr_we_o   = 1'b1;
                                                  wb_sel_o   = 2'b0; 
                                  end
                       3'h6:      begin           alu_op_o   = ALU_OR;
                                                  a_sel_o    = 2'b0;
                                                  b_sel_o    = 3'b1;
                                                  gpr_we_o   = 1'b1;
                                                  wb_sel_o   = 2'b0; 
                                  end
                       3'h7:      begin           alu_op_o    = ALU_AND;
                                                  a_sel_o    = 2'b0;
                                                  b_sel_o    = 3'b1;
                                                  gpr_we_o   = 1'b1;
                                                  wb_sel_o   = 2'b0; 
                                  end
                       3'h1:      begin      if ( funct7 == 7'h00 ) 
                                               begin
                                                 alu_op_o    = ALU_SLL;
                                                 a_sel_o    = 2'b0;
                                                 b_sel_o    = 3'b1;
                                                 gpr_we_o   = 1'b1;
                                                 wb_sel_o   = 2'b0; 
                                               end
                                             else
                                               illegal_instr_o = 1'b1;                
                                  end
                       3'h5:                           case( funct7 )
                                                       7'h00:           begin        alu_op_o   = ALU_SRL;
                                                                                     a_sel_o    = 2'b0;
                                                                                     b_sel_o    = 3'b1;
                                                                                     gpr_we_o   = 1'b1;
                                                                                     wb_sel_o   = 2'b0; 
                                                                        end
                                                       7'h20:           begin        alu_op_o   = ALU_SRA;
                                                                                     a_sel_o    = 2'b0;
                                                                                     b_sel_o    = 2'b1;
                                                                                     gpr_we_o   = 1'b1;
                                                                                     wb_sel_o   = 2'b0; 
                                                                        end
                                                       default:                      illegal_instr_o = 1'b1;  
                                                       endcase
                       3'h2:       begin         alu_op_o   = ALU_SLTS;
                                                 a_sel_o    = 2'b0;
                                                 b_sel_o    = 3'b1;
                                                 gpr_we_o   = 1'b1;
                                                 wb_sel_o   = 2'b0; 
                                   end
                       3'h3:       begin        alu_op_o    = ALU_SLTU;
                                                a_sel_o    = 2'b0;
                                                b_sel_o    = 3'b1;
                                                gpr_we_o   = 1'b1;
                                                wb_sel_o   = 2'b0; 
                                   end
                       default:                 illegal_instr_o = 1'b1; 
                        endcase
       7'b0000011:     case ( funct3 )
                       3'h0:      begin       alu_op_o   = ALU_ADD;
                                              a_sel_o    = 2'b0;
                                              b_sel_o    = 3'b1;
                                              mem_req_o  = 1'b1;
                                              mem_we_o   = 1'b0;
                                              mem_size_o = 3'd0;
                                              gpr_we_o   = 1'b1;
                                              wb_sel_o   = 2'b1; 
                                  end
                       3'h1:      begin       alu_op_o   = ALU_ADD;
                                              a_sel_o    = 2'b0;
                                              b_sel_o    = 3'b1;
                                              mem_req_o  = 1'b1;
                                              mem_we_o   = 1'b0;
                                              mem_size_o = 3'd1;
                                              gpr_we_o   = 1'b1;
                                              wb_sel_o   = 2'b1;
                                  end
                      3'h2:       begin       alu_op_o   = ALU_ADD;
                                              a_sel_o    = 2'b0;
                                              b_sel_o    = 3'b1;
                                              mem_req_o  = 1'b1;
                                              mem_we_o   = 1'b0;
                                              mem_size_o = 3'd2;
                                              gpr_we_o   = 1'b1;
                                              wb_sel_o   = 2'b1;
                                  end
                      3'h4:       begin       alu_op_o   = ALU_ADD;
                                              a_sel_o    = 2'b0;
                                              b_sel_o    = 3'b1;
                                              mem_req_o  = 1'b1;
                                              mem_we_o   = 1'b0;
                                              mem_size_o = 3'd4; 
                                              gpr_we_o   = 1'b1;
                                              wb_sel_o   = 2'b1;
                                  end  
                     3'h5:        begin       alu_op_o   = ALU_ADD;
                                              a_sel_o    = 2'b0;
                                              b_sel_o    = 3'b1;
                                              mem_req_o  = 1'b1;
                                              mem_we_o   = 1'b0;
                                              mem_size_o = 3'd5;
                                              gpr_we_o   = 1'b1;
                                              wb_sel_o   = 2'b1;
                                  end   
                    default:              illegal_instr_o = 1'b1;                     
                     endcase
       7'b0100011:   case ( funct3 )
                     3'h0:        begin       alu_op_o   = ALU_ADD;
                                              a_sel_o    = 2'b0;
                                              b_sel_o    = 3'd3;
                                              mem_req_o  = 1'b1;
                                              mem_we_o   = 1'b1;
                                              mem_size_o = 3'd0;
                                              gpr_we_o   = 1'b0;  
                                  end   
                3'h1:             begin       alu_op_o   = ALU_ADD;
                                              a_sel_o    = 2'b0;
                                              b_sel_o    = 3'd3;
                                              mem_req_o  = 1'b1;
                                              mem_we_o   = 1'b1;
                                              mem_size_o = 3'd1;
                                              gpr_we_o   = 1'b0;  
                                  end
               3'h2:              begin       alu_op_o   = ALU_ADD;
                                              a_sel_o    = 2'b0;
                                              b_sel_o    = 3'd3;
                                              mem_req_o  = 1'b1;
                                              mem_we_o   = 1'b1;
                                              mem_size_o = 3'd2;
                                              gpr_we_o   = 1'b0;
                                  end          
              default:                       illegal_instr_o = 1'b1;   
                     endcase
      7'b1100011:    case ( funct3 )
                     3'h0:        begin      alu_op_o    =  ALU_EQ;
                                             a_sel_o     =  2'b0;
                                             b_sel_o     =  3'b0;
                                             branch_o    =  1'b1;
                                  end
                     3'h1:        begin      alu_op_o    =  ALU_NE;
                                             a_sel_o     =  2'b0;
                                             b_sel_o     =  3'b0;
                                             branch_o    =  1'b1;
                                  end
                     3'h4:        begin      alu_op_o    =  ALU_LTS;
                                             a_sel_o     =  2'b0;
                                             b_sel_o     =  3'b0;
                                             branch_o    =  1'b1;
                                  end
                     3'h5:        begin      alu_op_o    =  ALU_GES;
                                             a_sel_o     =  2'b0;
                                             b_sel_o     =  3'b0;
                                             branch_o    =  1'b1;
                                  end   
                     3'h6:        begin      alu_op_o    =  ALU_LTU;
                                             a_sel_o     =  2'b0;
                                             b_sel_o     =  3'b0;
                                             branch_o    =  1'b1;
                                  end  
                     3'h7:        begin      alu_op_o    =  ALU_GEU;
                                             a_sel_o     =  2'b0;
                                             b_sel_o     =  3'b0;
                                             branch_o    =  1'b1;
                                  end    
                     default:                illegal_instr_o = 1'b1;             
                     endcase
     7'b1101111:     begin                   alu_op_o    =  ALU_ADD;
                                             a_sel_o     =  2'b1;
                                             b_sel_o     =  3'd4;
                                             jal_o       =  1'b1;
                                             gpr_we_o    =  1'b1;
                                             wb_sel_o    = 2'b0;
                     end 
     7'b1100111:     begin                   if ( funct3 == 3'h0) begin
                                             alu_op_o    =  ALU_ADD;
                                             a_sel_o     =  2'b1;
                                             b_sel_o     =  3'd4;
                                             jalr_o      =  1'b1;
                                             gpr_we_o    =  1'b1;
                                             wb_sel_o    =  2'b0;
                                             end
                                             else illegal_instr_o = 1'b1;
                     end
     7'b0110111:
                     begin                  alu_op_o     =  ALU_ADD;
                                            a_sel_o      =  2'd2;
                                            b_sel_o      =  3'd2;
                                            wb_sel_o     =  1'b0;
                                            gpr_we_o     =  1'b1;
                                            wb_sel_o     =  2'b0;
                     end
     7'b0010111:     begin                  alu_op_o     =  ALU_ADD;
                                            a_sel_o      =  2'b1;
                                            b_sel_o      =  3'd2;
                                            gpr_we_o     =  1'b1;
                                            wb_sel_o     =  1'b0;
                                            
                     end
     7'b0001111:    begin                        if( funct3 == 3'h0 ) 
                                                 illegal_instr_o = 1'b0;
                                                 else
                                                 illegal_instr_o = 1'b1;
                    end 
     
     7'b1110011:     begin   case ( funct3 )
                             3'h0:                  case( funct7 )
                                                      7'h18:         case ( rd )
                                                                       5'h0:     case ( rs1 )
                                                                                   5'h0:        case ( rs2 )
                                                                                                  5'b00010:     mret_o   = 1'b1; 
                                                      default: illegal_instr_o = 1'b1;            
                                                    endcase
                                                                     default: illegal_instr_o = 1'b1;            
                                                                     endcase
                                                                                 default: illegal_instr_o = 1'b1;            
                                                                                 endcase
                                                                                                default: illegal_instr_o = 1'b1;            
                             
                                                                                               endcase
                            
                             3'h1:       begin      csr_we_o     =  1'b1;
                                                    gpr_we_o     =  1'b1;
                                                    wb_sel_o     =  2'd2;
                                                    csr_op_o     =  CSR_RW;             
                                         end
                             3'h2:       begin      csr_we_o     =  1'b1;
                                                    gpr_we_o     =  1'b1;
                                                    wb_sel_o     =  2'd2;
                                                    csr_op_o     =  CSR_RS;             
                                         end
                             3'h3:       begin      csr_we_o     =  1'b1;
                                                    gpr_we_o     =  1'b1;
                                                    wb_sel_o     =  2'd2;
                                                    csr_op_o     =  CSR_RC;             
                                         end
                             3'h5:       begin      csr_we_o     =  1'b1;
                                                    gpr_we_o     =  1'b1;
                                                    wb_sel_o     =  2'd2;
                                                    csr_op_o     =  CSR_RWI;             
                                         end
                             3'h6:       begin      csr_we_o     =  1'b1;
                                                    gpr_we_o     =  1'b1;
                                                    wb_sel_o     =  2'd2;
                                                    csr_op_o     =  CSR_RSI;  
                                         end 
                             3'h7:       begin      csr_we_o     =  1'b1;
                                                    gpr_we_o     =  1'b1;
                                                    wb_sel_o     =  2'd2;
                                                    csr_op_o     =  CSR_RCI;             
                                         end          
                             
                                               
                             default:               illegal_instr_o = 1'b1; 
                             
                             endcase
                                            
                      end   
  default:                   illegal_instr_o = 1'b1; 
                                                                                 
endcase                       

end


endmodule