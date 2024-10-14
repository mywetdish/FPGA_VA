#ifndef VA_LIB_H
#define VA_LIB_H

#include <iostream>
#include <memory>
#include <cstdint>
#include <string>

extern "C" {

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// RTE
#include <rte_common.h>
#include <rte_errno.h>
#include <rte_log.h>
#include <rte_eal.h>
#include <rte_ethdev.h>
#include <rte_lcore.h>
#include <rte_mempool.h>
#include <rte_mbuf.h>

// QDMA PMD
#include <rte_pmd_qdma.h>
}
/*
#define TEST_DEV_ID 0
#define TEST_RING_DEPTH 256
#define TEST_BUFF_SIZE 4096
*/
#define DEVICES_MAX 256

#define RX_BURST_SIZE 8 // from example driver
#define RX_MAX_RETRY 10000 // from example driver

#define MBUF_POOL_NAME_PORT "mbuf_pool_%d"

#define MAX(x, y) (((x) > (y)) ? (x) : (y))

typedef struct {
    bool is_open;
	int32_t config_bar_idx;
	int32_t user_bar_idx;
	int32_t bypass_bar_idx;
	uint32_t queue_base;
	uint32_t nb_descs;
	uint32_t buff_size;
	char mem_pool[RTE_MEMPOOL_NAMESIZE];
} device_info;

extern uint16_t device_num;
extern device_info devices[DEVICES_MAX];

void va_deinit(struct rte_device *rte_dev);
using qdma_dev_ptr = std::unique_ptr<struct rte_device, decltype(&va_deinit)>;
qdma_dev_ptr va_init(uint16_t dev_id, uint32_t ring_depth, uint32_t buff_size);

int va_xmit(uint16_t dev_id, uint8_t *data, uint32_t len);
int va_recv(uint16_t dev_id, uint8_t *data, uint32_t len);

#endif // VA_LIB_H