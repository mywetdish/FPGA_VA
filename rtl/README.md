# RTL

## Requirements

* [AMD Virtex UltraScale+ FPGA VCU128 Evaluation Kit](https://www.xilinx.com/products/boards-and-kits/vcu128.html) or any other QDMA-compatible FPGA (project .tcl script should be edited in this case);
* [Vivado Design Suite](https://www.xilinx.com/products/design-tools/vivado.html); current project was built and tested in `2023.1`

## Build

### Using TCL script

Execute Vivado in batch mode to generate Vivado project in this folder:

```bash
vivado -mode batch -source fpga_va_qdma_vcu128.tcl
```

To create project in different directory, execute following:

```bash
mkdir -p projects
cd projects
vivado -mode batch -source <path_to_this_repository>/rtl/fpga_va_qdma_vcu128.tcl -tclargs [ --origin_dir "<path_to_this_repository>/rtl/" ]
```

### Install xilinx vivado cable drivers

To install the Windows driver, run the following commands in an Administrator command prompt:

```bash
cd %VIVADO_INSTALL_DIR%\data\xicom\cable_drivers\nt64
install_drivers_wrapper.bat %log_dir%
```

To install the Linux driver, enter the following commands as root:

```bash
cd ${vivado_install_dir}/data/xicom/cable_drivers/lin64/install_script/install_drivers/
./install_drivers
```

### Creating xdc file for your board from vivado example project

Choose qdma ip block in your project:

![image](https://github.com/user-attachments/assets/40d3c99f-8df4-462c-b9e5-ec6fa9185fc7)

Then select "Open IP Example Design"

![image](https://github.com/user-attachments/assets/af3e5883-9062-4637-b1ec-2fb6653c1449)

Here it is! Copy xdc to your project

![image](https://github.com/user-attachments/assets/46e56707-c1fd-4568-955d-3d22f31c358a)
