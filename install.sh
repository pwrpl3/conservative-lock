#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script as root or using sudo."
  exit 1
fi

echo "Setting up USB lock/unlock mechanism..."

echo "Removing old USB-related udev rules..."
rm -f /etc/udev/rules.d/*usb*.rules

echo "Creating /usr/local/bin/usb_locker.sh..."
cat << 'EOF' > /usr/local/bin/usb_locker.sh
#!/bin/bash
i-kilit
EOF

echo "Creating /usr/local/bin/usb_killer.sh..."
cat << 'EOF' > /usr/local/bin/usb_killer.sh
#!/bin/bash
/usr/bin/pkill -9 -f kilit
EOF

chmod +x /usr/local/bin/usb_locker.sh
chmod +x /usr/local/bin/usb_killer.sh

echo "Creating /etc/udev/rules.d/99-usb-kill.rules..."
cat << 'EOF' > /etc/udev/rules.d/99-usb-kill.rules
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="058f", ATTRS{idProduct}=="6387", RUN+="/usr/local/bin/usb_killer.sh"
EOF

echo "Creating /etc/udev/rules.d/99-usb-auth.rules..."
cat << 'EOF' > /etc/udev/rules.d/99-usb-auth.rules
ACTION=="remove", SUBSYSTEM=="usb", ENV{PRODUCT}=="58f/6387/100", RUN+="/usr/local/bin/usb_locker.sh"
EOF

echo "Reloading udev rules..."
udevadm control --reload-rules
udevadm trigger

echo "Installation complete!"
