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

The radio shows up on USB as `35F0:B001` (Bitcraze AB, Crazyradio 2.0 Thread), a USB CDC ACM serial port.

## Status

Tested with two Crazyradio 2.0 and the OpenThread POSIX host (`ot-cli`): forming a network, joining it and pinging
in both directions without lost or retried frames.

Tested with Home Assistant Container, an OpenThread Border Router container and the matter.js Matter server:
Matter-over-Thread bulbs and a battery-powered button commissioned from the Home Assistant Android app.

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

The firmware works with the factory bootloader of the Crazyradio 2.0, nothing else needs to be updated. It goes in the
same place as the Crazyradio firmware, so the two can be swapped back and forth.

Hold the button on the Crazyradio 2.0 while plugging it in. A USB drive named `Crazyradio2` appears; copy
`zephyr.uf2` to it. To go back to the Crazyradio firmware, do the same with its UF2 file.

A Crazyradio already running this firmware can be put in bootloader mode without the button:

```
just bootloader
```

This finds the first radio with USB ID `35F0:B001`, or takes a serial port as argument, and sends it the OpenThread
reset to bootloader request (Spinel reset type bootloader). Stop the border router first, it holds the serial port.

With a debug probe connected, `just flash` flashes with probe-rs instead.

## Using it with Home Assistant

1. Plug the Crazyradio 2.0 into the Home Assistant host. It shows up as a USB serial port
   (`/dev/serial/by-id/usb-Bitcraze_AB_Crazyradio_2.0_Thread_...`).
2. Install the OpenThread Border Router add-on and select that serial port as the device. The baud rate does not
   matter for USB CDC ACM.
3. Install the Matter Server add-on and the Matter integration, then commission Matter devices from the Home
   Assistant Companion app. The phone commissions over Bluetooth; the Crazyradio only carries the Thread traffic.

When the border router runs on a Linux host you manage yourself, for example a Home Assistant Container install with
the border router in its own container, the host must forward IPv6 between the local network and the Thread network.
Without it, devices join the Thread network but commissioning stops at "connecting to device", because nothing on the
local network can reach them. Enable forwarding and keep it across reboots:

```
printf 'net.ipv6.conf.all.forwarding = 1\nnet.ipv6.conf.eth0.accept_ra = 2\n' | sudo tee /etc/sysctl.d/99-thread-border-router.conf
sudo sysctl --system
```

Replace `eth0` with the host's network interface. `accept_ra = 2` keeps the host accepting router advertisements on
that interface with forwarding enabled.

## License

Licensed under either of [Apache License, Version 2.0](LICENSE-APACHE) or [MIT license](LICENSE-MIT) at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in this project by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.
