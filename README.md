# Crazyradio 2.0 Thread firmware

Turns a Crazyradio 2.0 into an OpenThread radio co-processor (RCP), so it can be used as the radio of an OpenThread
Border Router, for example the one in Home Assistant, to control Thread and Matter-over-Thread devices.

This firmware has no Crazyflie support. Flash the [Crazyradio 2.0 firmware](https://github.com/bitcraze/crazyradio2-firmware)
to use the radio with a Crazyflie again.

The firmware is the unmodified [nRF Connect SDK](https://github.com/nrfconnect/sdk-nrf) OpenThread coprocessor sample
built for the Crazyradio 2.0. This repository adds:

- `boards/`: the Crazyradio 2.0 board definition, including the nRF21540 front-end module that the SDK drives for
  every frame
- `rcp.conf` and `rcp.overlay`: Spinel over USB CDC ACM to the host
- `module/`: restarts into the UF2 bootloader when the host asks for bootloader mode

## Building

The first time, enter the Python venv and fetch the nRF Connect SDK, Zephyr SDK and Python dependencies:

```
. enter.sh
just prepare-system
```

Then build:

```
just build
```

The firmware is written to `build/coprocessor/zephyr/zephyr.uf2`.

## Flashing

Hold the button on the Crazyradio 2.0 while plugging it in. A USB drive named `Crazyradio2` appears; copy
`zephyr.uf2` to it. To go back to the Crazyradio firmware, do the same with its UF2 file.

A Crazyradio already running this firmware can be put in bootloader mode without the button:

```
just bootloader
```

This sends the OpenThread reset to bootloader request (Spinel reset type bootloader), so stop the border router
first, it holds the serial port.

With a debug probe connected, `just flash` flashes with probe-rs instead.

## Using it with Home Assistant

1. Plug the Crazyradio 2.0 into the Home Assistant host. It shows up as a USB serial port
   (`/dev/serial/by-id/usb-Bitcraze_AB_Crazyradio_2.0_Thread_...`).
2. Install the OpenThread Border Router add-on and select that serial port as the device. The baud rate does not
   matter for USB CDC ACM.
3. Install the Matter Server add-on and the Matter integration, then commission Matter devices from the Home
   Assistant Companion app. The phone commissions over Bluetooth; the Crazyradio only carries the Thread traffic.

## License

Licensed under either of [Apache License, Version 2.0](LICENSE-APACHE) or [MIT license](LICENSE-MIT) at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in this project by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.
