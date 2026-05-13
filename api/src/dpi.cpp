#include "../inc/dpi.h"

DPI_LINK_DECL DPI_DLLESPEC
void dpi_va_dev_step(
    const svBitVecVal* data_in, 
    uint32_t data_in_size, 
    uint32_t data_out_size, 
    svBitVecVal* data_out
) {
    va_xmit(TEST_DEV_ID, (uint8_t*)data_in, data_in_size);
    va_recv(TEST_DEV_ID, (uint8_t*)data_out, data_out_size);
}
