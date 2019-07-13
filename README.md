# Install Script

This is an install script that will install Mycroft via the git installation method, create the systemd script, install Pulseaudio as a system wide service and optionally install Spotifyd (arm version), the Finished Booting skill and the Respeaker Mic Array v2.0 Pixel Ring skill. **Note: If you choose not to install Mimic locally or have speaker issues after reboot you may have to use the ```mycroft-cli-client``` command to view the pairing code**

## Usage
* **Download the script into /home/pi**
  <br>```wget https://raw.githubusercontent.com/arraylabs/mycroft_install_script/master/mycroft_install.sh```
* **Add execution bit to downloaded file**
  <br>```chmod +x mycroft_install.sh```
* **Run as pi user**
  <br>```./mycroft_install.sh```
* **Follow the interactive install**

## Requirements

* **Raspberry Pi 3 or 3B+/4B+**
  <br>_Older Raspberry Pi versions do not have sufficient processing power, and if they work they will be very slow_
* **Rasbian Buster**
  <br>Fresh install of Raspbian Buster
* **Audio input and output devices compatible with Mycroft**
  <br>This script is built to support the Respeaker Mic Array v2.0 USB device but may work with other devices
