// SPDX-FileCopyrightText: © 2023 Uri Shaked <uri@wokwi.com>
// SPDX-FileCopyrightText: © 2023 Hirosh Dabui <hirosh@dabui.de>
// SPDX-License-Identifier: MIT

#include <stddef.h>
#include <stdint.h>

#define IO_BASE 0x10000000
#define CYCLE_CNT_ADDR (IO_BASE + 0x18)
#define PWM_ADDR (IO_BASE + 0x14)
#define SPI_DIV (IO_BASE + 0x500010)
#define UART_LSR (IO_BASE + 0x5)
#define UART_RX (IO_BASE)
#define UART_TX (IO_BASE)
#define LSR_THRE 0x20
#define LSR_TEMT 0x40
#define LSR_DR 0x01

volatile char *uart_tx = (char *)UART_TX, *uart_rx = (char *)UART_RX,
              *uart_lsr = (char *)UART_LSR;

void uart_putc(char c) {
  while (!(*uart_lsr & (LSR_THRE | LSR_TEMT)))
    ;
  *uart_tx = c;
}

char uart_getc() {
  while (!(*uart_lsr & LSR_DR))
    ;
  return *uart_rx;
}

const char hex_chars[] = "0123456789ABCDEF";
void uart_puthex_byte(uint8_t byte) {
  uart_putc(hex_chars[byte >> 4]);
  uart_putc(hex_chars[byte & 0xF]);
}

void uart_puthex(const void *data, size_t size) {
  const uint8_t *bytes = (const uint8_t *)data;
  for (size_t i = 0; i < size; i++) {
    uart_puthex_byte(bytes[i]);
    uart_putc(' ');
  }
}


struct spi_regs {
  volatile uint32_t *ctrl, *data;
} spi = {(volatile uint32_t *)0x10500000, (volatile uint32_t *)0x10500004};

static void spi_set_cs(int cs_n) { *spi.ctrl = cs_n; }
static int spi_xfer(char *tx, char *rx) {
  while ((*spi.ctrl & 0x80000000) != 0)
    ;
  *spi.data = (tx != NULL) ? *tx : 0;
  while ((*spi.ctrl & 0x80000000) != 0)
    ;
  if (rx)
    *rx = (char)(*spi.data);
  return 0;
}

uint8_t SPI_transfer(char tx) {
  uint8_t rx;
  spi_xfer(&tx, &rx);
  return rx;
}

#define CS_ENABLE() spi_set_cs(1)
#define CS_DISABLE() spi_set_cs(0)

int main() {
  uint32_t *spi_div = (volatile uint32_t *)SPI_DIV;
  uint32_t *pwm = (volatile uint32_t *)PWM_ADDR;
  uint32_t *cycles = (volatile uint32_t *)CYCLE_CNT_ADDR;

  uint8_t rx = 0;
  CS_ENABLE();
  if ((rx = SPI_transfer(0xde)) != 0xde >> 1)
    return 1;
  if ((rx = SPI_transfer(0xad)) != 0xad >> 1)
    return 1;
  if ((rx = SPI_transfer(0xbe)) != 0xdf >> 0)
    return 1;
  if ((rx = SPI_transfer(0xaf)) != 0xaf >> 1)
    return 1;
  CS_DISABLE();

  /* :) */
  volatile uint32_t get_cycles = *cycles;
  *pwm = 0xaa;


  for (char *str = "Hello UART\n"; *str; uart_putc(*str++))
    ;

  while (1) {
    char c = uart_getc();
    uart_putc(c >= 'A' && c <= 'Z' ? c + 32 : c);
  }

  return 0;
}
