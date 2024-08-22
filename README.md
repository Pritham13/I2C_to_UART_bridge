# I2C to UART Unidirectional Bridge

This project implements a unidirectional bridge that converts I2C communication to UART. It receives data via I2C and transmits it through UART.
## Links
- I2C 
    - [I2C module](/i2c_modules/i2c_recv.v)
    - [I2C README](/i2c_modules/README.md)
- UART 
    - [UART module](/uart_module/uart_tx.v)
    - [UART README](/uart_module/README.md)
- FIFO
    - [FIFO module](/fifo_module/fifo.v)
    - [FIFO README](/fifo_module/README.md)
    - [FIFO depth Calculation](/fifo_module/FIFO_depth_calc.md)

## Overview

The bridge consists of three main components:
1. I2C Slave Receiver
2. FIFO (First-In-First-Out) Buffer
3. UART Transmitter

Data flow: I2C → FIFO → UART

## Module Structure

- `top`: The main module that integrates all components
- `i2c_slave`: Receives data from I2C
- `fifo`: Buffers data between I2C and UART
- `uart_tx`: Transmits data via UART

## Inputs and Outputs

### Inputs:
- `i_SCL`: I2C clock line
- `i_SDA`: I2C data line
- `i_reset`: System reset

### Output:
- `o_TX`: UART transmit line

## Key Features

- Unidirectional data flow from I2C to UART
- FIFO buffering to manage data rate differences
- Automatic flow control using FIFO underflow and UART transmission status

## Operation

1. I2C data is received by the `i2c_slave` module.
2. Received data is written to the FIFO buffer.
3. UART transmitter reads data from the FIFO when it's ready to transmit.
4. Flow control is managed automatically based on FIFO status and UART transmission status.

## Notes

- The system uses the I2C clock (SCL) as the main clock for all modules.
- UART transmission is enabled when there's data in the FIFO and the UART is not actively transmitting.

## Future Improvements

- Implement error handling for I2C communication
- Add status indicators for system operation
- make it Multi directional
