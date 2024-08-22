# FIFO Depth Calculation

Given:
- **Input I2C data rate**: `400 kbit/s`
- **Output data rate for FIFO**: `115,200 bit/s`
- **Limit of transmission**: `100 bytes`

## Time Required to Store 1 Byte via I2C

The time required to store 1 byte is calculated as:

$$
\text{{Time required for 1 byte}} = \frac{9}{f_{\text{{i2c}}}} = \frac{9}{400000} = 2.25 \times 10^{-5} \, \text{{seconds}}
$$

## Time Required for 100 Bytes Transmission

The time required for transmitting 100 bytes is:

$$
\text{{Time required for 100 bytes}} = \text{{Time required for 1 byte}} \times 100 = 2.25 \times 10^{-5} \times 100 = 2.25 \times 10^{-3} \, \text{{seconds}}
$$

## Bytes Transmitted by UART in the Same Duration

The number of bytes transmitted by UART in 2.25 * 10 ^ -3 seconds is calculated as:

$$
\text{{Bytes transmitted by UART}} = 2.25 \times 10^{-3} \times \frac{115200}{10} = 2.25 \times 10^{-3} \times 11520 = 25.9 \approx 25
$$

## FIFO Depth Required

The FIFO depth required is:

$$
\text{{FIFO Depth}} = 100 - 25 = 75 \, \text{{bytes}}
$$
