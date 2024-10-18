`timescale 1ns / 1ps

module interrupt_controller(
                                 input  logic                   clk_i,
                                 input  logic                   rst_i,
                                 input  logic             exception_i,
                                 input  logic               irq_req_i,
                                 input  logic                   mie_i,
                                 input  logic                  mret_i,
                                 
                                 output logic               irq_ret_o,
                                 output logic [31:0]      irq_cause_o,
                                 output logic                   irq_o
);

logic exc_h;
logic irq_h;

assign irq_cause_o = 32'h1000_0010;

assign irq_ret_o = mret_i & ~(exc_h | exception_i );

assign irq_o = ( irq_req_i & mie_i )  & ~( irq_h | ( exception_i  | exc_h)  );

always_ff @ (  posedge clk_i or posedge rst_i )
  if ( rst_i ) 
    exc_h <= 1'b0;
  else
    exc_h <= ( (exc_h | exception_i ) & ~ mret_i);
    
    
always_ff @ (  posedge clk_i or posedge rst_i )
  if ( rst_i ) 
    irq_h <= 1'b0;
  else
    irq_h <= ( (irq_h | irq_o ) & ~ mret_i);


endmodule
