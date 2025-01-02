SIM = verilator
TOPLEVEL_LANG = verilog
GTKWAVE = gtkwave

VERILOG_SOURCE_DIR = $(PWD)/../../00_source/src

VERILOG_SOURCES += $(wildcard $(VERILOG_SOURCE_DIR)/**/*.v)
VERILOG_SOURCES += $(wildcard $(VERILOG_SOURCE_DIR)/**/**/*.v)
INCLUDE_DIRS = $(dir $(wildcard $(VERILOG_SOURCE_DIR)/**/*.vh))

VERILATOR_FLAGS = -j 0 $(addprefix -I, $(INCLUDE_DIRS))
COMPILE_ARGS += $(VERILATOR_FLAGS)
EXTRA_ARGS += --trace --trace-structs

include $(shell cocotb-config --makefiles)/Makefile.sim

build:
	echo "Building the project..."

run: clean
	$(MAKE) TOPLEVEL=eth_top MODULE=tb_eth_top

wave: run
	$(GTKWAVE) dump.vcd $(CURDIR)/eth_top.gtkw
