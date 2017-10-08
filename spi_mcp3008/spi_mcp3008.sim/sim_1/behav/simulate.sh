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
ExecStep $xv_path/bin/xsim spi_master_tb_behav -key {Behavioral:sim_1:Functional:spi_master_tb} -tclbatch spi_master_tb.tcl -log simulate.log
