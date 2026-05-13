module uart_rx_sb_ctrl(
/*
    Часть интерфейса модуля, отвечающая за подключение к системной шине
*/
  input  logic          clk_i,
  input  logic          rst_i,
  input  logic [31:0]   addr_i,
  input  logic          req_i,
  input  logic [31:0]   write_data_i,
  input  logic          write_enable_i,
  output logic [31:0]   read_data_o,

/*
    Часть интерфейса модуля, отвечающая за отправку запросов на прерывание
    процессорного ядра
*/

  output logic        interrupt_request_o,
  input  logic        interrupt_return_i,

/*
    Часть интерфейса модуля, отвечающая за подключение передающему,
    входные данные по UART
*/
  input  logic          rx_i
);

(* mark_debug = "true" *)  logic busy;
(* mark_debug = "true" *)  logic [16:0] baudrate;
(* mark_debug = "true" *)  logic parity_en;
(* mark_debug = "true" *)  logic stopbit;
(* mark_debug = "true" *)  logic [7:0]  data;
(* mark_debug = "true" *)  logic [7:0] rx_data;
(* mark_debug = "true" *)  logic valid;
(* mark_debug = "true" *)  logic rx_valid;
(* mark_debug = "true" *) logic rx_busy;
  logic rst;
  assign rst = rst_i | ( write_enable_i & addr_i == 32'h0000_0024 );
  
  always_ff @( posedge clk_i )
    if( rst )
        busy <= 1'd0;
    else
        busy <= rx_busy;
        
  always_ff @( posedge clk_i )
    if( rst )
        baudrate <= 17'd9600;
    else if( write_enable_i & addr_i == 32'h0000_000C & ~rx_busy )
        baudrate <= write_data_i[16:0];
        
  always_ff @( posedge clk_i )
    if( rst )
        parity_en <= 1'd1;
    else if( write_enable_i & addr_i == 32'h0000_0010 & ~rx_busy )
        parity_en <= write_data_i[0];
        
  always_ff @( posedge clk_i )
    if( rst )
        stopbit <= 1'd1;
    else if( write_enable_i & addr_i == 32'h0000_0014 & ~rx_busy )
        stopbit <= write_data_i[0];
        
  always_ff @( posedge clk_i )
    if( rst )
        data <= 8'd0;
    else if( rx_valid )
        data <= rx_data;
        
  always_ff @( posedge clk_i )
    if( rst )
        valid <= 1'd0;
    else if( rx_valid )
        valid <= 1'd1;
    else if( write_enable_i & addr_i == 32'h0000_0000 & ~rx_busy | interrupt_return_i )
        valid <= 1'd0;
    
assign interrupt_request_o = valid;
  //read_data
logic [31:0] read_data;
always_comb begin
    case( addr_i[23:0] )
        24'h0:  read_data = { 24'd0, data };
        24'h4:  read_data = { 31'd0, valid };
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
        
        
uart_rx rx(
  .clk_i      (clk_i      ),
  .rst_i      (rst        ),
  .rx_i       (rx_i       ),
  .busy_o     (rx_busy    ),
  .baudrate_i (baudrate   ),
  .parity_en_i(parity_en  ),
  .stopbit_i  (stopbit    ),
  .rx_data_o  (rx_data    ),
  .rx_valid_o (rx_valid   )
);



endmodule