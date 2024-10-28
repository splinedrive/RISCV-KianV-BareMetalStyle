# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
#SIM_ARGS=-fst
#SIM ?= verilator
TOPLEVEL_LANG ?= verilog
PROJ = $(PWD)/../src

VERILOG_SOURCES += $(PWD)/tb.v
VERILOG_SOURCES += $(PWD)/spiflash.v
VERILOG_SOURCES += $(PWD)/psram.v

# normal simulation
ifneq ($(GATES),yes)

# this is the only part you should need to modify:
VERILOG_SOURCES += $(PROJ)/tt_um_kianv_bare_metal.v # $(PROJ)/decoder.v
VERILOG_SOURCES += $(PROJ)/tx_uart.v
VERILOG_SOURCES += $(PROJ)/spi.v
VERILOG_SOURCES += $(PROJ)/rx_uart.v
VERILOG_SOURCES += $(PROJ)/qqspi.v
VERILOG_SOURCES += $(PROJ)/soc.v
VERILOG_SOURCES += $(PROJ)/fifo.v
VERILOG_SOURCES += $(PROJ)/pwm.v
VERILOG_SOURCES += $(PROJ)/riscv_defines.vh
VERILOG_SOURCES += $(PROJ)/alu_decoder.v
VERILOG_SOURCES += $(PROJ)/register_file.v
VERILOG_SOURCES += $(PROJ)/design_elements.v
VERILOG_SOURCES += $(PROJ)/riscv_defines.vh
VERILOG_SOURCES += $(PROJ)/main_fsm.v
VERILOG_SOURCES += $(PROJ)/control_unit.v
VERILOG_SOURCES += $(PROJ)/store_decoder.v
VERILOG_SOURCES += $(PROJ)/datapath_unit.v
VERILOG_SOURCES += $(PROJ)/load_decoder.v
VERILOG_SOURCES += $(PROJ)/extend.v
VERILOG_SOURCES += $(PROJ)/load_alignment.v
VERILOG_SOURCES += $(PROJ)/kianv_harris_mc_edition.v
VERILOG_SOURCES += $(PROJ)/alu.v
VERILOG_SOURCES += $(PROJ)/store_alignment.v
VERILOG_SOURCES += $(PROJ)/defines_soc.vh

COMPILE_ARGS    += -I$(PROJ)

else

# gate level simulation requires some extra setup, you shouldn't need to touch this
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DSIM
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_io/verilog/sg13g2_io.v
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog/sg13g2_stdcell.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v
endif

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb

# MODULE is the basename of the Python test file
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
