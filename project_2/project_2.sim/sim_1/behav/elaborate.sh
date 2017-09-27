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
ExecStep $xv_path/bin/xelab -wto 437b2d4d51cc4062bf028a32d4373876 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot flasher_behav xil_defaultlib.flasher xil_defaultlib.glbl -log elaborate.log
