`timescale 1ns / 1ps

module timer_sb_ctrl (

  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        req_i,
  input  logic        write_enable_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] write_data_i,
                                  
  output logic [31:0] read_data_o,
  output logic        ready_o,

  output logic        interrupt_request_o
);

logic reset;

logic [63:0] system_counter;
logic [63:0] delay;
enum logic [1:0] {OFF, NTIMES, FOREVER} mode, next_mode;
logic [31:0] repeat_counter;
logic [63:0] system_counter_at_start;

assign reset = rst_i | ( (addr_i == 32'h24) & ( write_data_i == 'd1 ) );

always_ff @( posedge clk_i  )
  if ( reset )
    system_counter <= 'd0;
  else
    system_counter <= system_counter + 1'd1;

always_ff @( posedge clk_i  )
  if ( reset )
    delay <= 'd0;
  else if 
    ( write_enable_i && (addr_i == 32'h08) )
      delay[31:0] <= write_data_i;
  else if
    ( write_enable_i && (addr_i == 32'h0c) )
      delay[63:32] <= write_data_i;
    

always_ff @( posedge clk_i ) begin
  if ( reset )
    mode <= OFF;
  else
    mode <= next_mode;
end

always_comb begin
  next_mode = mode;
    case ( mode )
      OFF:
        if ( ( addr_i == 32'h10 ) && (  write_enable_i && (write_data_i == 32'd1) ) )
          next_mode = NTIMES;
        else if ( ( addr_i == 32'h10 ) && (  write_enable_i  && (write_data_i == 32'd2) ))
            next_mode = FOREVER;      
      NTIMES:
        if ( repeat_counter == 32'd0 )
          next_mode = OFF;
        else if ( ( addr_i == 32'h10 ) &&  ( write_enable_i && (write_data_i == 32'd0) ) )
          next_mode = OFF;
        else if (  ( addr_i == 32'h10 ) && ( write_enable_i && (write_data_i == 32'd2) ) )
            next_mode = FOREVER;
      FOREVER:
        if ( ( addr_i == 32'h10 ) && (write_enable_i &&  (write_data_i == 32'd0 )) )
          next_mode = OFF;
        else if ( ( addr_i == 32'h10 ) && ( write_enable_i && (write_data_i == 32'd1) ) )
          next_mode = NTIMES;
    endcase
end
        
always_ff @( posedge clk_i )
  if ( reset )
    repeat_counter = 32'd0;
  else if ( addr_i == 32'h14 && write_enable_i )
    repeat_counter = write_data_i;
  else if ( mode == NTIMES  && ( interrupt_request_o == 1'd1 ))
    repeat_counter <= repeat_counter - 1'd1;
    
always_ff @ ( posedge clk_i )
  if ( reset ) 
    system_counter_at_start <= 64'd0;
  else if ( (interrupt_request_o == 1'b1) &&  repeat_counter != 'd0)
    system_counter_at_start <= system_counter;
  else if ( ( addr_i == 32'h10 ) && (write_enable_i) && ( write_data_i == 'd1 || write_data_i == 'd2 ) )
    system_counter_at_start <= system_counter;
  else
    system_counter_at_start <= system_counter_at_start;
    
assign interrupt_request_o = ( ( mode == NTIMES ) || ( mode == FOREVER) )  && ( system_counter > system_counter_at_start + delay);

always_comb begin
  case ( addr_i )
    'h00:
      read_data_o = system_counter[31:0];
    'h04:
      read_data_o = system_counter[63:32];
    'h08:
      read_data_o = delay[31:0];
    'h0c:
      read_data_o = delay[63:32];
    'h10:
      read_data_o = mode;
    'h14:
      read_data_o = repeat_counter;
  endcase
end

endmodule