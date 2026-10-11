#!/bin/bash
# Instaluje usluge LTE dla XMM7360. Uruchom: sudo bash install.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Uruchom przez sudo: sudo bash $0" >&2
    exit 1
fi

SRC=$(cd "$(dirname "$0")" && pwd)

echo "==> zaleznosci python"
pacman -S --needed --noconfirm python-pyroute2 python-configargparse python-dbus

echo "==> xmm7360-pci do /opt (wlasciciel root)"
rm -rf /opt/xmm7360-pci
cp -r "$SRC/xmm7360-pci" /opt/xmm7360-pci
chown -R root:root /opt/xmm7360-pci
chmod -R go-w /opt/xmm7360-pci

echo "==> skrypty, usluga, polkit, konfiguracja"
install -m755 "$SRC/xmm7360-connect" "$SRC/xmm7360-disconnect" /usr/local/bin/
install -m644 "$SRC/xmm7360.service" /etc/systemd/system/
install -m644 "$SRC/49-xmm7360.rules" /etc/polkit-1/rules.d/
[ -e /etc/xmm7360 ] || install -m644 "$SRC/xmm7360.ini" /etc/xmm7360
systemctl daemon-reload

echo "==> ModemManager nie obsluguje tego modemu -- wylaczam"
systemctl disable --now ModemManager 2>/dev/null || true

echo
echo "Gotowe. Polacz:  systemctl start xmm7360"
echo "        Rozlacz: systemctl stop xmm7360"
echo "        APN:     sudo nano /etc/xmm7360"
