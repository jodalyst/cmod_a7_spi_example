#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2017.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 0cbcdf754c6e4d0b82f1498b8b044bb5 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot spi_master_tb_behav xil_defaultlib.spi_master_tb xil_defaultlib.glbl -log elaborate.log
