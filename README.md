# About

## Units

**Ptah**: Project Builder

**Sia**: Compute Unit

**Wadjet**: Debug Unit

**Thoth**: IO Unit

**Nets**: Predefined networks configurations

**Service**: Service HW modules

## Add changes to Git

Use [Ptah Project Builder](./Ptah/) to generate `.tcl` script and build the project. The project will use files from source directories, so the Git detects changes automatically.

Add new files to the source directories if you want to commit them to Git.

## More

See the `docs` directory to find out how to use project.

# TODO

## Repository

- [ ] Add Readme descriptions for every module in every unit

## Configurator script

- [ ] Add Configurator script to easily create Network with any topology.
- [ ] [Blocked] Provide a simple interface for connecting the UART module for data logging.


## Ptah

### `ptah.py` - Build Vivado project script

- [X] Input list of modules to generate tcl scripts. (SW)
- [X] Allow to chnge FPGA_PART. (SW)
- [X] Visualize dependency strcture. (SW)

## Sia

### `/Sia/Soma_Izh_Simpl_HW` - Simplified version of Soma_Izh_HW

- [ ] Implement the hardware module. (HW)
- [ ] Find out how many neurons will fit on the chip (one-way connections) (Research)
  - [ ] Soma_Izh_HW
  - [ ] [Blocked] Soma_Izh_Simpl_HW

## Wadjet
- [ ] Rate how often to send data from FPGA to PC. (Research)
- [ ] Flexible connection of the module to other modules. (HW)
  - [ ] Connecting to single module.
  - [ ] Connecting to multiple modules.
- [ ] Add multi-producer support. (SW + HW)
- [ ] Prepare data for transmission: Add Sync bits (4 bytes `0xAABBCCDD`). (SW + HW)s
- [ ] Logging received data into the .log text file. (SW)
- [ ] Charts plotter. (SW)

## Thoth
- [ ] Implement signal reading from FPGA pin using Arduino. (SW + HW)
- [ ] Implement motor control using FPGA. (SW + HW)

## Nets
- [ ] Devise a useful network design based on available resources. (Research)

## Other
- [ ] Check the correctness of `clock_div`. Should it be implemented via `enable` bit? (Research)
