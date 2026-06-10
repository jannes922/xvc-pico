/*
  Copyright (c) 2017 Jean THOMAS.

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the "Software"),
  to deal in the Software without restriction, including without limitation
  the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the Software
  is furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/**
 * @brief Handle a DirtyJTAG command
 *
 * @param usbd_dev USB device
 * @param transfer Received packet
 * @return Command needs to send data back to host
 */
void cmd_handle(uint8_t* rxbuf, uint32_t count, uint8_t* tx_buf);

static int tdi_gpio = 16;
static int tdo_gpio = 17;
static int tck_gpio = 18;
static int tms_gpio = 19;

#define JTAG_ITF     1

#define LED_PIN      25

// Settle time (in nops) between driving TCK low and sampling TDO. The value
// of 3 was tuned on the RP2040 (M0+ @ 125 MHz); the faster dual-issue RP2350
// plus its GPIO input synchronizer needs more - with 3 it produces occasional
// single-bit TDO errors and Vivado fails to enumerate the chain, with 8 it
// reads cleanly.
#if PICO_RP2350
#define jtag_delay   8
#else
#define jtag_delay   3
#endif
