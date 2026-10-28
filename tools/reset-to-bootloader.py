#!/usr/bin/env python3
"""Reset a Crazyradio 2.0 running the Thread firmware to its UF2 bootloader.

Sends the Spinel reset command with the bootloader reset type, the same
request an OpenThread host sends for "reset bootloader".
"""

import argparse
import struct

import serial
from serial.tools import list_ports

SPINEL_HEADER = 0x81  # Command flag, interface 0, transaction 1
SPINEL_CMD_RESET = 1
SPINEL_RESET_BOOTLOADER = 3


def crc16(data):
    fcs = 0xFFFF
    for b in data:
        fcs ^= b
        for _ in range(8):
            fcs = (fcs >> 1) ^ 0x8408 if fcs & 1 else fcs >> 1
    return fcs ^ 0xFFFF


def hdlc_frame(payload):
    raw = payload + struct.pack("<H", crc16(payload))
    frame = bytearray([0x7E])
    for b in raw:
        if b in (0x7E, 0x7D, 0x11, 0x13, 0xF8):
            frame += bytes([0x7D, b ^ 0x20])
        else:
            frame.append(b)
    frame.append(0x7E)
    return bytes(frame)


def find_radio():
    for port in list_ports.comports():
        if port.manufacturer == "Bitcraze AB" and port.product == "Crazyradio 2.0 Thread":
            return port.device
    return None


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("port", nargs="?", help="serial port, the first Crazyradio 2.0 Thread found if left out")
    args = parser.parse_args()

    port = args.port or find_radio()
    if port is None:
        parser.error("no Crazyradio 2.0 Thread found")

    with serial.Serial(port) as radio:
        radio.write(hdlc_frame(bytes([SPINEL_HEADER, SPINEL_CMD_RESET, SPINEL_RESET_BOOTLOADER])))
        radio.flush()
    print(f"Reset {port} to the UF2 bootloader")


if __name__ == "__main__":
    main()
