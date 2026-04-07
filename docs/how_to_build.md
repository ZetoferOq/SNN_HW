# How to build Vivado project

## Generate build_generated.tcl script

Use build.py script in the root of repository. The resulting `build_generated.tcl` script will be created in the root of repository.

```bash
./buid.py "<module_type>/<module_name>"
```

### Example

Run `build.py` script using Spyder:

![Build using Spyder](./media/how_to_build_0.png)

## Run build_generated.tcl script in Vivado

![Run Tcl script 0](./media/how_to_build_1.png)

![Run Tcl script 1](./media/how_to_build_2.png)

## Enjoy

![Run Tcl script 1](./media/how_to_build_3.png)

## Notes

- If the Vivado project wasn't saved, you can find temp project copy in the `C:\Users\<user_name>\AppData\Roaming\Xilinx\Vivado` directory.
