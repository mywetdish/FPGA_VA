#include <linux/module.h>
#define INCLUDE_VERMAGIC
#include <linux/build-salt.h>
#include <linux/elfnote-lto.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;
BUILD_LTO_INFO;

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif

static const struct modversion_info ____versions[]
__used __section("__versions") = {
	{ 0xc6a83232, "module_layout" },
	{ 0x9a353ae, "__x86_indirect_alt_call_rax" },
	{ 0xc960d0a8, "param_ops_charp" },
	{ 0x4ab89651, "param_ops_int" },
	{ 0xbb26b5f4, "pci_unregister_driver" },
	{ 0x8756978d, "__pci_register_driver" },
	{ 0xe2d5255a, "strcmp" },
	{ 0x92997ed8, "_printk" },
	{ 0xb8a46024, "uio_unregister_device" },
	{ 0x3ccd5d23, "_dev_warn" },
	{ 0x87a21cb3, "__ubsan_handle_out_of_bounds" },
	{ 0xde80cd09, "ioremap" },
	{ 0x37a0cba, "kfree" },
	{ 0xefa80af4, "pci_disable_device" },
	{ 0xedc03953, "iounmap" },
	{ 0x1135e9b5, "sysfs_remove_group" },
	{ 0xfa6c5933, "dma_free_attrs" },
	{ 0x423cd59f, "dma_alloc_attrs" },
	{ 0xa907afdd, "__uio_register_device" },
	{ 0x8f7d8e45, "sysfs_create_group" },
	{ 0xba16ab81, "dma_set_coherent_mask" },
	{ 0x5aa2509d, "dma_set_mask" },
	{ 0x46310c0d, "pci_enable_device" },
	{ 0xe71025ce, "kmem_cache_alloc_trace" },
	{ 0xb0549baa, "kmalloc_caches" },
	{ 0x7fc79ad4, "pci_msi_unmask_irq" },
	{ 0x385a6461, "pci_intx" },
	{ 0xdde7f81b, "pci_msi_mask_irq" },
	{ 0xea000f26, "pci_cfg_access_unlock" },
	{ 0x23d5c2e5, "pci_cfg_access_lock" },
	{ 0xa5aa503c, "irq_get_irq_data" },
	{ 0x2b2e9044, "_dev_notice" },
	{ 0xbf7f420, "_dev_err" },
	{ 0x9ad33e59, "__dynamic_dev_dbg" },
	{ 0x7ec56044, "pci_irq_vector" },
	{ 0x3720b79f, "pci_alloc_irq_vectors_affinity" },
	{ 0x49a03d4a, "_dev_info" },
	{ 0x92d5838e, "request_threaded_irq" },
	{ 0x3a662c70, "pci_set_master" },
	{ 0xb58919ce, "pci_check_and_mask_intx" },
	{ 0xa4bb0d43, "uio_event_notify" },
	{ 0x4a4d155c, "pci_free_irq_vectors" },
	{ 0xc1514a3b, "free_irq" },
	{ 0xe1a6b511, "pci_clear_master" },
	{ 0x656e4a6e, "snprintf" },
	{ 0x2ea2c95c, "__x86_indirect_thunk_rax" },
	{ 0xd0da656b, "__stack_chk_fail" },
	{ 0x27540565, "pci_enable_sriov" },
	{ 0xb966f59f, "pci_disable_sriov" },
	{ 0x6b8aadea, "pci_num_vf" },
	{ 0x5c3c7387, "kstrtoull" },
	{ 0xbdfb6dbb, "__fentry__" },
};

MODULE_INFO(depends, "uio");


MODULE_INFO(srcversion, "477CD0B44C1D25E57128F06");
