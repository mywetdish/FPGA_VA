module uart_tx_sb_ctrl(
/*
    ����� ���������� ������, ���������� �� ����������� � ��������� ����
*/
  input  logic          clk_i,
  input  logic          rst_i,
  input  logic [31:0]   addr_i,
  input  logic          req_i,
  input  logic [31:0]   write_data_i,
  input  logic          write_enable_i,
  output logic [31:0]   read_data_o,

/*
    ����� ���������� ������, ���������� �� ����������� �����������,
    �������� ������ �� UART
*/
  output logic          tx_o
  
);

  logic busy;
  logic [16:0] baudrate;
  logic parity_en;
  logic stopbit;
  logic [7:0]  data;  
  logic tx_busy;
  logic rst;
  assign rst = rst_i | ( write_enable_i & addr_i == 32'h0000_0024 );
  
  //delete
  assign tx_valid_o = write_enable_i & addr_i == 32'h0000_0000 & ~tx_busy;
  assign tx_byte_o = data;
  //delete
  
  always_ff @( posedge clk_i )
    if( rst )
        busy <= 1'd0;
    else
        busy <= tx_busy;
        
  always_ff @( posedge clk_i )
    if( rst )
        baudrate <= 17'd9600;
    else if( write_enable_i & addr_i == 32'h0000_000C & ~tx_busy )
        baudrate <= write_data_i[16:0];
        
  always_ff @( posedge clk_i )
    if( rst )
        parity_en <= 1'd1;
    else if( write_enable_i & addr_i == 32'h0000_0010 & ~tx_busy )
        parity_en <= write_data_i[0];
        
  always_ff @( posedge clk_i )
    if( rst )
        stopbit <= 1'd1;
    else if( write_enable_i & addr_i == 32'h0000_0014 & ~tx_busy )
        stopbit <= write_data_i[0];
        
  always_ff @( posedge clk_i )
    if( rst )
        data <= 8'd0;
    else if( write_enable_i & addr_i == 32'h0000_0000 & ~tx_busy )
        data <= write_data_i[7:0];
        
  //read_data
logic [31:0] read_data;
always_comb begin
    case( addr_i[23:0] )
        24'h0:  read_data = { 24'd0, data };
        24'h8:  read_data = { 31'd0, busy };
        24'hC:  read_data = { 15'd0, baudrate };
        24'h10: read_data = { 31'd0, parity_en };
        24'h14: read_data = { 31'd0, stopbit };
        default: read_data = 32'd0;
    endcase
end

always_ff @( posedge clk_i, posedge rst_i )
    if( rst_i ) 
        read_data_o <= 32'd0;
    else if( req_i )
        read_data_o <= read_data;
  
uart_tx tx(
  .clk_i      (clk_i      ),
  .rst_i      (rst        ),
  .tx_o       (tx_o       ),
  .busy_o     (tx_busy    ),
  .baudrate_i (baudrate   ),
  .parity_en_i(parity_en  ),
  .stopbit_i  (stopbit    ),
  .tx_data_i  (write_data_i[7:0]       ),
  .tx_valid_i ( write_enable_i & addr_i == 32'h0000_0000 & ~tx_busy )
);

endmodule