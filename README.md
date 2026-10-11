# xmm7360-systemd

Get LTE working on laptops with the **Intel XMM7360 / Fibocom L850-GL** modem
(PCI ID `8086:7360`, e.g. ThinkPad X1 Carbon Gen 7/8, T490, T14 Gen 1) on a
modern kernel, as a simple systemd service.

ModemManager does not support this modem in RPC mode. This project instead uses
the in-kernel `iosm` driver for the device nodes and the userspace RPC scripts
from [xmm7360-pci](https://github.com/xmm7360/xmm7360-pci) to bring the
connection up.

Tested on: ThinkPad X1 Carbon Gen 8, CachyOS (Arch), kernel 7.x, Play (PL) SIM.

## What's included

| File | Purpose |
|---|---|
| `xmm7360-pci/` | Vendored copy of upstream xmm7360-pci with patches (see below) |
| `xmm7360-connect` | Loads `iosm`, runs `open_xdatachannel.py`, sets DNS via systemd-resolved |
| `xmm7360-disconnect` | Brings `wwan0` down and unloads `iosm` (turns the radio off) |
| `xmm7360.service` | `systemctl start/stop xmm7360` |
| `49-xmm7360.rules` | polkit: members of `wheel` may start/stop the service without a password |
| `xmm7360.ini` | Config installed to `/etc/xmm7360` (set your APN here) |
| `install.sh` | Installs everything (Arch: uses `pacman` for Python deps) |

## Install

```sh
sudo bash install.sh
sudo nano /etc/xmm7360     # set apn= for your carrier
systemctl start xmm7360    # connect
systemctl stop xmm7360     # disconnect + radio off
```

The installer **disables ModemManager**, since it cannot drive this modem anyway.
On non-Arch distros, install `pyroute2`, `ConfigArgParse` and `dbus-python`
yourself and remove the `pacman` line.

The service is not enabled at boot. Run `systemctl enable xmm7360` if you want it to start at boot.
Logs: `/var/log/xmm7360.log`.

## Patches to upstream xmm7360-pci

- `rpc/rpc.py`: tolerate unknown payload type `0x05` in `unpack_unknown`.
  Some SIM cards (seen on Play) send SIM Toolkit messages that crashed the
  RPC parser.
- pyroute2 API compatibility fix for current pyroute2 releases.

## DankMaterialShell widget

A bar widget showing the connection state lives in a separate repo:
[dms-lte-status](https://github.com/frankizaw/dms-lte-status).

## License

`xmm7360-pci/` is © its upstream authors (genua GmbH, James Wah and
contributors). The kernel module source is dual-licensed GPL-2.0 OR
BSD-3-Clause (see the header of `xmm7360-pci/xmm7360.c`).
Everything else in this repository is MIT licensed (see `LICENSE`).
