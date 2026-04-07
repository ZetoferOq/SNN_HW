# About

See the `docs` directory to find out how to use project.

# TODO

## Configurator script

- [ ] Add Configurator script to easily create Network with any topology.
- [ ] [Blocked] Provide a simple interface for connecting the UART module for data logging.

## `/Network/Soma_Izh_Simpl_HW` - Simplified version of Soma_Izh_HW

- [ ] Implement the hardware module

## `/Service/UART` - Debug interface

- [ ] Logging received data into the .log text file. (SW)
- [ ] Add 4 synchronization bytes `0xAABBCCDD`. (SW + HW)
- [ ] [Blocked] Add multi-producer support. (SW + HW)
- [ ] [Blocked] Rate how often to send data from FPGA to PC.

## `build.py` - Build Vivado project script

- [ ] Do not allow to create project if there are no sources in specified didrectory.
- [ ] Add flexible configuration. Ex: specify FPGA_PART as an argument.

## Research

- [ ] Find out how many neurons will fit on the chip (one-way connections)
  - [ ] Soma_Izh_HW
  - [ ] [Blocked] Soma_Izh_Simpl_HW
- [ ] Implement signal reading from FPGA pin using Arduino
- [ ] Implement motor control using FPGA
- [ ] Check the correctness of `clock_div`. Should it be implemented via `enable` bit?
