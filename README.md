# SC22_ACAP
## Framework Overview
**This repo includes an automatic code generation(ACG) framework XACG for generating the source code targeting on dense matrix-matrix multiply(MM) for AMD/XILINX VCK190 and VCK5000 platforms**. 

**XACG** takes platform information and user-specified design point as input, and automatically generated the systen-level design by launching the following 3 template based components sequentially:<br>
**XACG-KernelGen:** XACG-KernelGen is launched to generate both the single AI Engine(AIE) C code and adaptive data flow (ADF) graph code in C++ for verfying the correctness of single kernel design. MM kernels with int16, int32, fp32 data type in different shape that can be fit in single kernel are supported in current version.<br>

**XACG-IOGen:** Based on the single kernel created by XACG-KernelGen, XACG-IOGen is launched to generate new ADF graph code that defines how packet-switch streams are connected to AIE array which contains 400 AIEs. Single kernel calculating 32x32x32 MM with int32 and fp32 data type is supported to scale out to the AIE array. <br>

**XACG-SysGen:** Based on the AIE array created by XACG-IOGen, XACG-SysGen is launched to generate PL streams, scheduling controller modules to communicate with AIE array and PL on-chip buffers, off-chip AXI data transfer modules to communicate with DDR. Differnet system level designs varying in on-chip buffer size and its implementation option (BRAM or URAM) for int32 and fp32 data type are supported.<br>

![XACG](https://user-images.githubusercontent.com/77606152/163127636-76361ad2-8057-4f91-9211-cfd0b2c13c8b.png)<br>

## Configuration File 
In the following configuration file, users can specify platform, data type, kernel type and mapping strategy of each level. The feasible option of each parameter are illustrated in **( )** The rules of using this configuration file are listed below:
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

## Experiment Environment<br>
Following environments are automatically set when launch each ACGs. The detail can be viewed in run.aie.sh or run.sys.sh after generating the corresponding code. <br>
1. VCK5000: Vitis 2021.2, XRT 2021.2 <br>
```sh
source /opt/tools/xilinx/Vitis/2021.2/settings64.sh
source /opt/xilinx/xrt/setup.sh
```
2. VCK190: Vitis 2021.1 <br>
```sh
VIV_VER=2021.1 SDA_VER=2021.1 . with-sdaccel
```

## Demo<br>
In this section, we take fp32 datatype of case 2 as an exmple to demonstrate how our framework works. In our experiment, we specify the single kernel computation as 32x32x32 and tiling factor of A, B and C to 12, 8, 4 respectively. All the different size listed in Table VI are the result of different X, Y, Z and T_Z. X, Y, Z are specified in **input.cfg** file, whereas T_Z is configured in /host/host.cpp. Thus for case 2 the corrsponded number of X, Y, Z and T_Z are shown bellow. To reproduce our experiment result, one can simply change the number of X, Y, Z since T_Z will be automatical generated.<br>
- Case 2 : 1536 × 2048 × 128 × 200 -> X=4, Y=8, Z=1, T_Z=200<br>

![image](https://user-images.githubusercontent.com/77606152/163144535-3d8dd67e-21da-4d1b-a0ac-4600cfbd9e5f.png)<br>

After getting the parameters, four simple steps are needed to reproduce the results.<br>
**1. Download Repo**<br>
```sh
git clone https://github.com/JinmingZhuang/SC22_ACAP.git
git checkout master
```
**2. Modify input.cfg file**<br>
```sh
Platform:VCK5000;
KernelGen:1;
	DATA_TYPE:fp32;
	KRL_TYPE:1;
	I:32;
	K:32;
	J:32;
IOGen:1;
	DATA_TYPE:fp32;
	A:12;
	B:8;
	C:4;
SysGen:1;
	DATA_TYPE:fp32;
	X:4;
	Y:8;
	Z:1;
	LHS_BUFF:1;
	RHS_BUFF:0;
	OUT_BUFF:1;
```
**3. Launch XACG**<br>
```sh
./AutoGen
```

**4. Run experiment on VCK5000 and see result in log file**<br>
```sh
source /opt/tools/xilinx/Vitis/2021.2/settings64.sh
source /opt/xilinx/xrt/setup.sh
cd ${SYS_PRO_PATH}
./hostexe mm_hw.xclbin >> result.log
```


**It takes 6-8 hours to go through the whole processes and the expected throughput should be 4.3-4.4 TFLOPs**

## Experiment customization<br>
**1.System level Throuput Experiment**<br>
To reproduce the other experiment results, one can simply change the number of X, Y, Z and T_Z will be automatical generated. We listed our settings below. Users can use XACG in the same way as mentioned in demo section.<br>
- Case 1 : 1536 × 1024 × 256 × 320 -> X=4, Y=4, Z=2, T_Z=320, [LHS_BUFF,RHS_BUFF,OUT_BUFF]=[1,0,1]
- Case 2 : 1536 × 2048 × 128 × 200 -> X=4, Y=8, Z=1, T_Z=200, [LHS_BUFF,RHS_BUFF,OUT_BUFF]=[1,0,1]
- Case 3 :  768 × 1280 × 384 × 320 -> X=2, Y=5, Z=3, T_Z=320, [LHS_BUFF,RHS_BUFF,OUT_BUFF]=[1,1,0]
- Case 4 :  768 × 1792 × 256 × 320 -> X=2, Y=7, Z=2, T_Z=320, [LHS_BUFF,RHS_BUFF,OUT_BUFF]=[1,1,0]
- Case 5 : 1536 × 1792 × 128 × 200 -> X=4, Y=7, Z=1, T_Z=200, [LHS_BUFF,RHS_BUFF,OUT_BUFF]=[1,0,1]

**2. Resource utilization and timig report**<br>
1. For VCK5000
```sh
cd SysGen/script_VCK5000
./hw_parse.sh 
./time_parse.sh
```

2. For VCK190
```sh
cd SysGen/script_VCK190
./hw_parse.sh 
./time_parse.sh
```
**3. Single Kernel Effciency**<br>
In this section, users can launch the KernelGen independently by assigning Sys_Gen and IO_Gen to 0. We prepared the input and golden data of the data point listed in Table II and III for correctness verification. In the rest of this section, we will use int32 MM kernel 0 with size 32*32*32 as an example to showcase how to verify correctness and efficiency of a single kernel. <br>

![image](https://user-images.githubusercontent.com/77606152/163173087-bd8604f9-d069-47a1-8a9c-0c0845e410ce.png)<br>

1. **Modify input.cfg file**<br>
```sh
Platform:VCK190;
KernelGen:1;
	DATA_TYPE:int32;
	KRL_TYPE:0;
	I:32;
	K:32;
	J:32;
IOGen:0;
	DATA_TYPE:any;
	A:any;
	B:any;
	C:any;
SysGen:0;
	DATA_TYPE:any;
	X:any;
	Y:any;
	Z:any;
	LHS_BUFF:any;
	RHS_BUFF:any;
	OUT_BUFF:any;
```

2. **Lauch KernelGen**<br>
```sh
either cd KernelGen; ./KernelGen.sh;
or ./AutoGen.sh
```

3. Verify Correctness(Provide golden output file for design points listed in TABLE II and III)<br>

4. Verify Single kernel Efficiency. <br>
```sh
VIV_VER=2021.1 SDA_VER=2021.1 . with-sdaccel   #VCK190 Environment
cd ${KEL_PRO_PATH}
vitis_analyzer aiesimulator_output/default.aierun_summary
```
After open the GUI of vitis_analyzer, we mark the start time and stop time of mm_kernel0 as shown in the following picture. The total elapsed cycle can be calculated as 5483-1154=4329 cycles. For int32 data type, it can calucalte 8 MACs/cyc. The theoretical execution cycle should be 32*32*32/8=4096 cycles. Thus the efficiency can be calculated as EFF = 4096/4329 ≈ 94.6%. Note that, there are small number of cycles variation during different launch of a single kernel thus lead to small changes in efficiency.<br>

![image](https://user-images.githubusercontent.com/77606152/163173178-0ac63bb5-fc3e-43b5-9ec1-90f2fda5c764.png)<br>
