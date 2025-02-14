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

VERILOG_SOURCE_DIR = $(PWD)/../../00_source/src
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_tx/eth_tx_pkg.sv
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_tx/eth_tx_ctrl.sv
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_tx/eth_tx.sv
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_rx/eth_rx_ctrl.sv
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_rx/eth_rx.sv
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_top/clk_rst_mgr.sv
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_top/eth_mdio.sv
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_top/eth_regs.sv
VERILOG_SOURCES += $(VERILOG_SOURCE_DIR)/eth_top/eth_top.sv

VERILATOR_FLAGS = -j 0 -I$(VERILOG_SOURCE_DIR) -I$(VERILOG_COMMON_DIR)
COMPILE_ARGS += $(VERILATOR_FLAGS)
EXTRA_ARGS += --trace --trace-structs

include $(shell cocotb-config --makefiles)/Makefile.sim

build:
	echo "Building the project..."

run: clean
	$(MAKE) TOPLEVEL=eth_top MODULE=tb_eth_top

wave: run
	$(GTKWAVE) dump.vcd --script $(CURDIR)/tb_wave.tcl
