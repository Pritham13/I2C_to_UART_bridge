# FIFO Module

This is  Verilog implementation of a 16x8-bit FIFO (First-In-First-Out) module.

## Description

The FIFO module is designed to store and retrieve 8-bit data in a first-in-first-out manner. It has a depth of 16 entries and provides overflow and underflow indicators.

## Features

- 16 entries deep
- 8-bit data width
- Synchronous read and write operations
- Asynchronous reset
- Overflow and underflow indicators

## Inputs

- `i_data[7:0]`: 8-bit input data
- `en_read`: Read enable signal
- `en_write`: Write enable signal
- `reset`: Asynchronous reset signal
- `clk`: Clock signal

## Outputs

- `o_data[7:0]`: 8-bit output data
- `overflow`: Overflow indicator
- `underflow`: Underflow indicator

## Functionality

- Data is written when `en_write` is high and there's no overflow
- Data is read when `en_read` is high and there's no underflow
- The module supports simultaneous read and write operations
- `reset` signal initializes all registers to 0 and sets the write pointer to 15