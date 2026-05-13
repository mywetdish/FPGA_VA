# API 

## How to compile api?

Go to /api directory and use:

```bash
  make
```

## dpi_va_dev_step

```c
void dpi_va_dev_step(
    const svBitVecVal* data_in, 
    uint32_t data_in_size, 
    uint32_t data_out_size, 
    svBitVecVal* data_out
) 
```

```SystemVerilog
import "DPI-C" function void dpi_va_dev_step(
        input bit [`IN_BUS_LEN-1:0] data_in,
        input int unsigned data_in_size, 
        input int unsigned data_out_size,
        output bit [`OUT_BUS_LEN-1:0] data_out
    );

    initial begin
        forever begin
    	    @(posedge clk);
            dpi_va_dev_step(
                in_bus, 
                `IN_BUS_LEN/8, 
                `OUT_BUS_LEN/8, 
                out_bus
            );
        end
    end
```

This function provide simulation step by transmit your data into board, then receive output. 
