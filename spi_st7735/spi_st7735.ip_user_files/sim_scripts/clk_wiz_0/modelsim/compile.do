vlib work
vlib msim

vlib msim/xil_defaultlib
vlib msim/xpm

vmap xil_defaultlib msim/xil_defaultlib
vmap xpm msim/xpm

vlog -work xil_defaultlib -64 -incr -sv "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"/opt/Xilinx/Vivado/2017.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -64 -93 \
"/opt/Xilinx/Vivado/2017.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../ipstatic" "+incdir+../../../ipstatic" \
"../../../../spi_st7735.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_clk_wiz.v" \
"../../../../spi_st7735.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.v" \

vlog -work xil_defaultlib \
"glbl.v"
