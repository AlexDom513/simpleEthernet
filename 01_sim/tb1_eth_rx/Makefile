SIM = verilator
TOPLEVEL_LANG = verilog
GTKWAVE = gtkwave

VERILOG_COMMON_DIR = $(PWD)/../../00_source/src/common
VERILOG_SOURCES += $(VERILOG_COMMON_DIR)/eth_crc_gen.v
VERILOG_SOURCES += $(VERILOG_COMMON_DIR)/async_fifo/fifomem.v
VERILOG_SOURCES += $(VERILOG_COMMON_DIR)/async_fifo/rptr_empty.v
VERILOG_SOURCES += $(VERILOG_COMMON_DIR)/async_fifo/wptr_full.v
VERILOG_SOURCES += $(VERILOG_COMMON_DIR)/async_fifo/sync_r2w.v
VERILOG_SOURCES += $(VERILOG_COMMON_DIR)/async_fifo/sync_w2r.v
VERILOG_SOURCES += $(VERILOG_COMMON_DIR)/async_fifo/async_fifo.v

VERILOG_SOURCE_DIR = $(PWD)/../../00_source/src/eth_rx
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_rx.sv
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_rx_ctrl.sv

VERILATOR_FLAGS = -j 0 -I$(VERILOG_COMMON_DIR)
COMPILE_ARGS += $(VERILATOR_FLAGS)
EXTRA_ARGS += --trace --trace-structs

include $(shell cocotb-config --makefiles)/Makefile.sim

build:
	echo "Building the project..."

run: clean
	$(MAKE) TOPLEVEL=eth_rx MODULE=tb_eth_rx

wave: run
	$(GTKWAVE) dump.vcd $(CURDIR)/eth_rx.gtkw
