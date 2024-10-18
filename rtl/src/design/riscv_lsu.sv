`timescale 1ns / 1ps

module riscv_lsu(
                     input     logic                     clk_i,
                     input     logic                     rst_i,
                     
                     input     logic                 core_req_i,
                     input     logic                  core_we_i,
                     input     logic     [2:0]      core_size_i,
                     input     logic     [31:0]     core_addr_i, 
                     input     logic     [31:0]       core_wd_i, 
                     output    logic     [31:0]       core_rd_o,      
                     output    logic               core_stall_o,
                     
                     output    logic                  mem_req_o,
                     output    logic                   mem_we_o,
                     output    logic     [3:0]         mem_be_o,
                     output    logic     [31:0]      mem_addr_o,
                     output    logic     [31:0]        mem_wd_o,
                     input     logic     [31:0]        mem_rd_i,
                     input     logic                 mem_ready_i
);

logic stall_reg;

assign mem_req_o = core_req_i;
assign mem_we_o  = core_we_i;
assign mem_addr_o = core_addr_i;


always_comb
  begin
    if ( (core_req_i & core_we_i) ) begin
      case ( core_size_i[1:0] )
        2'd0:                  begin           case ( core_addr_i[1:0] )
                                                 2'b00:                    mem_be_o   = 4'b0001;
                                                 2'b01:                    mem_be_o   = 4'b0010;
                                                 2'b10:                    mem_be_o   = 4'b0100;
                                                 2'b11:                    mem_be_o   = 4'b1000;
                                               endcase
                               end
        2'd1:                  begin 
                                               if ( core_addr_i[1] )
                                                 mem_be_o      =    4'b1100;
                                               else
                                                 mem_be_o      =    4'b0011;
                               end     
        2'd2:
          mem_be_o = 4'b1111;                      
        endcase                     
    end
  end

always_comb
  begin
    case ( core_size_i[1:0] )
      2'd0:  mem_wd_o = { core_wd_i[7:0] , core_wd_i[7:0] , core_wd_i[7:0] , core_wd_i[7:0] };
      2'd1:  mem_wd_o = { core_wd_i[15:0] , core_wd_i[15:0] };
      2'd2:  mem_wd_o = core_wd_i;
    endcase
  end
always_comb
  begin
    case ( core_size_i )
      3'd0:              begin          case ( core_addr_i[1:0] )
                                          2'b00:                      core_rd_o  = { {24{mem_rd_i[7]}} , mem_rd_i[7:0]   };
                                          2'b01:                      core_rd_o  = { {24{mem_rd_i[15]}} , mem_rd_i[15:8]  };
                                          2'b10:                      core_rd_o  = { {24{mem_rd_i[23]}} , mem_rd_i[23:16] };
                                          2'b11:                      core_rd_o  = { {24{mem_rd_i[31]}} , mem_rd_i[31:24] };
                                        endcase
                         end
     3'd1:               begin
                                        case ( core_addr_i[1] )
                                          1'b0:                      core_rd_o  = { {16{mem_rd_i[15]}} , mem_rd_i[15:0]};
                                          1'b1:                      core_rd_o  = { {16{mem_rd_i[31]}} , mem_rd_i[31:16]};
                                        endcase
                         end  
     3'd2:               begin
                                        core_rd_o  = mem_rd_i;
                         end
     3'd4:               begin
                                        case ( core_addr_i[1:0] )
                                          2'b00:                      core_rd_o  = { 24'h000000, mem_rd_i[7:0] };
                                          2'b01:                      core_rd_o  = { 24'h000000, mem_rd_i[15:8]};
                                          2'b10:                      core_rd_o  = { 24'h000000, mem_rd_i[23:16]};
                                          2'b11:                      core_rd_o  = { 24'h000000, mem_rd_i[31:24]};
                                        endcase
                         end
     3'd5:               begin
                                        case ( core_addr_i[1] )
                                          1'b0:                      core_rd_o  = { 16'h0000 , mem_rd_i[15:0] };
                                          1'b1:                      core_rd_o  = { 16'h0000 , mem_rd_i[31:16]};
                                        endcase
                         end
    endcase            
  end

always_ff @( posedge clk_i or posedge rst_i ) begin
  if ( rst_i )
    stall_reg <= 1'b0;
  else
    stall_reg <= core_stall_o;
end

assign core_stall_o = core_req_i &  ~( stall_reg & mem_ready_i );

endmodule
