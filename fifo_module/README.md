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
- `i_en_read`: Read enable signal
- `i_en_write`: Write enable signal
- `i_reset`: Asynchronous reset signal
- `i_clk`: Clock signal

## Outputs

- `o_data[7:0]`: 8-bit output data
- `o_overflow`: Overflow indicator
- `o_underflow`: Underflow indicator

## Functionality

- Data is written when `i_en_write` is high and there's no overflow
- Data is read when `i_en_read` is high and there's no underflow
- The module supports simultaneous read and write operations
- `i_reset` signal initializes all registers to 0 and sets the write pointer to 15