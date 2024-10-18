#Path to fpga_va dir
FPGA_VA_DIR="/home/mwd24/FPGA_VA"

#FPGA id
FPGA_PF="01:00.0"

# Top simulation module select
TOP = tb

# Output directory
OUT = build

# Compilation options
COMP_OPTS = -sv -work work $(ALL)

# Simulation options
SIM_OPTS = -c \
           -batch \
           -sv_lib $(FPGA_VA_DIR)/api/libfpga_va \
           -do "run -all" \
           -voptargs="+acc" \
           -l $(OUT)/sim.log

# All Verilog / SystemVerilog files from example directory
TESTBENCH = src/tb.sv
DUT = riscv_unit.sv

ALL = $(TESTBENCH) $(DUT)

# Verbosity
v =

.PHONY: run compile clean connect

# Run target
run: compile
	sudo -E env $(v)vsim work.$(TOP) $(SIM_OPTS)

# Clean target
clean:
	sudo rm -rf $(OUT)

# Compile target
ifneq ($(ALL),) # Guard on compilation only from existing example
compile: $(ALL) $(OUT)
	$(v)vlib $(OUT)/work > $(OUT)/compile.log
	$(v)vmap work $(OUT)/work >> $(OUT)/compile.log
	$(v)vlog $(COMP_OPTS) >> $(OUT)/compile.log
endif

# Output directory target
$(OUT):
	@mkdir -p $@
connect: 
	sudo modprobe uio
	sudo insmod ${FPGA_VA_DIR}/lib/dpdk-stable/dpdk-kmods/linux/igb_uio/igb_uio.ko 
	sudo python3 ${FPGA_VA_DIR}/lib/dpdk-stable/usertools/dpdk-devbind.py -b igb_uio ${FPGA_PF}
	sudo python3 ${FPGA_VA_DIR}/lib/dpdk-stable/usertools/dpdk-devbind.py --status
