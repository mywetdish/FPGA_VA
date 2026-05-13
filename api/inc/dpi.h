#ifndef DPI_H
#define DPI_H

#ifdef __cplusplus
#define DPI_LINK_DECL  extern "C" 
#else
#define DPI_LINK_DECL 
#endif

#include "svdpi.h"
#include "va_lib.h"

DPI_LINK_DECL DPI_DLLESPEC
void
dpi_va_dev_step(
    const svBitVecVal* data_in,
    uint32_t data_in_size,
    uint32_t data_out_size,
    svBitVecVal* data_out);

#endif // DPI_H
