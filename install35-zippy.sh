#First, backup standard configs
TARGET_DIR="./backup"
FILES_TO_COPY=("/boot/firmware/cmdline.txt" "/boot/firmware/config.txt" "/etc/rc.local" "/etc/default/console-setup")

# target dir present?
if [ -d "$TARGET_DIR" ]; then
    echo "Target directory '$TARGET_DIR' exists. Will not touch."
else
    # Create directory
    sudo mkdir -p "$TARGET_DIR"
    echo "Target directory '$TARGET_DIR' created."

    # Copy files
    for file in "${FILES_TO_COPY[@]}"; do
        if [ -f "$file" ]; then
            sudo cp "$file" "$TARGET_DIR"
            echo "'$file' copied to '$TARGET_DIR' ."
        else
            echo "Warning: '$file' not present. Skipped."
        fi
    done
fi

#now install driver
echo "Installing drivers"
sudo apt install xserver-xorg-input-evdev xinput-calibrator -y
sudo cp -rf waveshare35b-v2.dtbo /boot/overlays/waveshare35b-v2.dtbo
sudo cp -rf 99-fbdev.conf /usr/share/X11/xorg.conf.d/99-fbdev.conf
sudo cp -rf 45-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf
sudo cp -rf 99-calibration.conf /usr/share/X11/xorg.conf.d/99-calibration.conf
sudo cp -rf 20-noglamor.conf /usr/share/X11/xorg.conf.d/20-noglamor.conf
sudo chmod 444 /usr/share/X11/xorg.conf.d/20-noglamor.conf
sudo cp -rf config35-zippy.txt /boot/firmware/config.txt
cat /boot/firmware/cmdline.txt cmd_ext.txt > cmdline2.txt
sudo cp -rf cmdline2.txt /boot/firmware/cmdline.txt
sudo cp -rf rc.local /etc/rc.local
sudo cp -rf console-setup /etc/default/console-setup

echo "Disable unused services"
sudo systemctl disable exim4 # Mail transfer agent
sudo systemctl disable avahi-daemon # mDNS/Bonjour
sudo systemctl disable triggerhappy # Hotkey daemon
sudo systemctl disable man-db.timer # Documentation indexer
sudo systemctl disable cups.service # Printer service
sudo systemctl disable bluetooth.service # Bluetooth
sudo systemctl disable ModemManager.service

sudo touch /etc/cloud/cloud-init.disabled # Disable cloud init - should only be done after first boot

echo "Disable wait for network service"
sudo systemctl disable NetworkManager-wait-online.service

echo "Now reboot for changes to take effect.."



