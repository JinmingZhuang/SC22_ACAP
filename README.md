# SC22_ACAP
## Framework Overview
**This repo includes an automatic code generation(ACG) framework XACG for generating the source code targeting on dense matrix-matrix multiply(MM) for AMD/XILINX VCK190 and VCK5000 platforms**. 

**XACG** takes platform information and user-specified design point as input, and automatically generated the systen-level design by launching the following 3 template based components sequentially:<br>
**XACG-KernelGen:** XACG-KernelGen is launched to generate both the single AI Engine(AIE) C code and adaptive data flow (ADF) graph code in C++ for verfying the correctness of single kernel design. MM kernels with int16, int32, fp32 data type in different shape that can be fit in single kernel are supported in current version.<br>

**XACG-IOGen:** Based on the single kernel created by XACG-KernelGen, XACG-IOGen is launched to generate new ADF graph code that defines how packet-switch streams are connected to AIE array which contains 400 AIEs. Single kernel calculating 32x32x32 MM with int32 and fp32 data type is supported to scale out to the AIE array. <br>

**XACG-SysGen:** Based on the AIE array created by XACG-IOGen, XACG-SysGen is launched to generate PL streams, scheduling controller modules to communicate with AIE array and PL on-chip buffers, off-chip AXI data transfer modules to communicate with DDR. Differnet system level designs varying in on-chip buffer size and its implementation option (BRAM or URAM) for int32 and fp32 data type are supported.<br>

![XACG](https://user-images.githubusercontent.com/77606152/163127636-76361ad2-8057-4f91-9211-cfd0b2c13c8b.png)<br>

## Configuration File 
In the following configuration file, users  can specify platform, data type, kernel type and mapping strategy of each level. The feasible option of each parameter are illustrated in **( )** The rules of using this configuration file are listed below:
- **Platform** refers to the hardware platform used in the project. VCK5000 and VCK190 are supported in the current framework.
- **KernelGen, IOGen, SysGen** decide if the corresponding ACG should be launched (1 refers to launch). According  to the framework overview, the upper level ACGs are based on the lower level ACGs. Thus, lower level ACG parameter should be 1 when launching the upper level ACGs.([KernelGen, IOGen, SysGen]=[1,0,0] | [1,1,0] | [1,1,1]). When launch control parameter=0, the following parameters in its scope won't work thus can be random number.
- When multiple launch control parameter are assigned to 1, **DATA_TYPE** should be kept the same;
- **I, K, J** refers to the MM size stored and calculated in a single AIE.
- **A, B, C** refers to the BATCH level parameter.
- **X, Y, Z** refers to the BLOCK level parameter.
- **LHS_BUFF, RHS_BUFF, OUT_BUFF** dicide the implmentation option for LHS, RHS and output buffers. 1 refers to URAM and 0 refers to BRAM. For example, LHS_BUFF=1 means LHS buffer is implemented by URAM.
```sh
Platform:VCK5000;         #(VCK5000 | VCK190)
KernelGen:1;              #(0 | 1) scope 1
	DATA_TYPE:int32;  #(int32 | int16 | fp32)
	KRL_TYPE:1;       #(0 | 1)
	I:32;             #MM with size I*K*J will be calculated in a single AIE
	K:32;            
	J:32;
IOGen:0;                  #(0 | 1) scope 2
	DATA_TYPE:int32;  #(int32 | fp32)
	A:12;             #BATCH Level patameter A, B, C
	B:8;              #A*B*C -> Number of AIEs in AIE array
	C:4;
SysGen:0;                 #(0 | 1) scope 3
	DATA_TYPE:int32;  #(int32 | fp32)
	X:4;              #BLOCK level parameter
	Y:8;              #X,Y,Z decide the on-chip buffer utilization
	Z:1;
	LHS_BUFF:1;       #On-chip buffer implementation option
	RHS_BUFF:0;      
	OUT_BUFF:1;      
```

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
