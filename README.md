# SC22_ACAP
Characterization HLS code of reading DDR to on-chip buffer is included in master branch. <br>
## Experiment settings<br>
1. The file name ${b}port/${a}bits_${b}p refers to ${b} AXI ports each with ${a} bits are accessing DDR at the same time. <br>
2. The "burst_length" and "outstanding number" can be viewed in ${b}port/${a}bits_${b}p/src/krnl_vckbench.cpp.<br> 
3. The data allocation manner in DDR is in ${b}port/${a}bits_${b}p/src/host.cpp line 73-77.<br>
## Run make file in Vitis Flow<br>
1.Set Cross Compile Environment
```sh
source ${PATH}/environment-setup-cortexa72-cortexa53-xilinx-linux
```
2.Set Vitis 2021.1 Environment
```sh
source /opt/tools/xilinx/Vitis/2021.1/settings64.sh
```
3.Create Project
```sh
make all TARGET=hw PLATFORM=${PATH}/xilinx_vck190_base_202110_1/xilinx_vck190_base_202110_1.xpfm EDGE_COMMON_SW=${PATH}/xilinx-versal-common-v2021.1 SYSROOT=${PATH}/sysroots/cortexa72-cortexa53-xilinx-linux
```
