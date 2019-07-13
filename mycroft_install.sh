#!/usr/bin/env bash

echo
echo 'Updating apt and installing wget, git, vim, unzip, htop'
echo

sleep 2

sudo apt-get update
sudo apt-get install -y wget git vim unzip htop

##########################################################################

sleep 2

echo
echo 'Starting Mycroft installation'
echo

sleep 2

cd ~/
git clone https://github.com/MycroftAI/mycroft-core.git
cd mycroft-core
bash dev_setup.sh

sudo mkdir /etc/mycroft
sudo mkdir /ramdisk
echo "tmpfs /ramdisk tmpfs rw,nodev,nosuid,size=20M 0 0" | sudo tee -a /etc/fstab > /dev/null
sed -i -e 's|"max_allowed_core_version": 19.2|"max_allowed_core_version": 19.2,\n  "ipc_path": "/ramdisk/mycroft/ipc/"|' /home/pi/.mycroft/mycroft.conf

echo
echo 'Mycroft installation complete'
echo

##########################################################################

sleep 2

echo
echo 'Starting Pulseaudio installation'
echo

sleep 2

cd ~/
sudo apt-get install -y pulseaudio

if [ -f /etc/systemd/system/pulseaudio.service ]
then
	sudo rm /etc/systemd/system/pulseaudio.service
fi

echo "[Unit]" | sudo tee -a /etc/systemd/system/pulseaudio.service > /dev/null
echo "Description=PulseAudio Daemon" | sudo tee -a /etc/systemd/system/pulseaudio.service > /dev/null
echo "" | sudo tee -a /etc/systemd/system/pulseaudio.service > /dev/null
echo "[Install]" | sudo tee -a /etc/systemd/system/pulseaudio.service > /dev/null
echo "WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/pulseaudio.service > /dev/null
echo "" | sudo tee -a /etc/systemd/system/pulseaudio.service > /dev/null
echo "[Service]" | sudo tee -a /etc/systemd/system/pulseaudio.service > /dev/null
echo "Type=simple" | sudo tee -a /etc/systemd/system/pulseaudio.service > /dev/null
echo "PrivateTmp=true" | sudo tee -a /etc/systemd/system/pulseaudio.service > /dev/null
echo "ExecStart=/usr/bin/pulseaudio --system --realtime --disallow-exit --no-cpu-limit" | sudo tee -a /etc/systemd/system/pulseaudio.service > /dev/null

echo "load-module module-native-protocol-tcp auth-anonymous=1" | sudo tee -a /etc/pulse/system.pa > /dev/null

sudo chmod +x /etc/systemd/system/pulseaudio.service
sudo systemctl enable pulseaudio.service

sudo usermod -aG pulse pi
sudo usermod -aG pulse-access pi

sudo usermod -aG pulse root
sudo usermod -aG pulse-access root

echo
echo 'Pulseaudio installation complete'
echo

##########################################################################

sleep 2

echo "Do you want to install Spotifyd?"
echo -n "Choice [y/n]: "
while true; do
  read -N1 -s key
  case $key in
    y)
      echo
      echo 'Starting Spotifyd installation'
      echo

      read -p "Enter Spotify Username: " username
      read -s -p "Enter Spotify Password: " password

      cd ~/
      curl -s https://api.github.com/repos/Spotifyd/spotifyd/releases/latest | jq --raw-output '.assets[0] | .browser_download_url' | wget -i - -O spotifyd.zip
      unzip spotifyd.zip
      rm spotifyd.zip

      if [ ! -d /home/pi/.spotifyd_cache ]
      then
        mkdir /home/pi/.spotifyd_cache
      fi

      if [ -f /etc/spotifyd.conf ]
      then
        sudo rm /etc/spotifyd.conf
      fi

      echo "[global]" | sudo tee -a /etc/spotifyd.conf > /dev/null
      echo "username = " $username | sudo tee -a /etc/spotifyd.conf > /dev/null
      echo "password = " $password | sudo tee -a /etc/spotifyd.conf > /dev/null
      echo "mixer = PCM" | sudo tee -a /etc/spotifyd.conf > /dev/null
      echo "volume-control = alsa # or alsa_linear, or softvol" | sudo tee -a /etc/spotifyd.conf > /dev/null
      echo "device_name = mycroft # Cannot contain spaces" | sudo tee -a /etc/spotifyd.conf > /dev/null
      echo "bitrate = 320 # 96|160|320" | sudo tee -a /etc/spotifyd.conf > /dev/null
      echo "cache_path = /home/pi/.spotifyd_cache" | sudo tee -a /etc/spotifyd.conf > /dev/null
      echo "volume-normalisation = false" | sudo tee -a /etc/spotifyd.conf > /dev/null

      if [ -f /etc/systemd/system/spotifyd.service ]
      then
        sudo rm /etc/systemd/system/spotifyd.service
      fi

      echo "[Unit]" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "Description=A spotify playing daemon" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "Documentation=https://github.com/Spotifyd/spotifyd" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "After=pulseaudio.service" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "Wants=sound.target" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "After=sound.target" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "Wants=network-online.target" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "After=network-online.target" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "[Service]" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "ExecStart=/home/pi/spotifyd --no-daemon" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "Restart=always" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "RestartSec=12" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null

      echo "[Install]" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null
      echo "WantedBy=default.target" | sudo tee -a /etc/systemd/system/spotifyd.service > /dev/null

      sudo chmod +x /etc/systemd/system/spotifyd.service
      sudo systemctl enable spotifyd.service

      echo
      echo 'Spotifyd installation complete'
      echo

      break
      ;;
    n)
      echo "Skipping Spotifyd installation"
      break
      ;;
  esac
done

##########################################################################

sleep 2

echo
echo 'Starting creation of mycroft service'
echo

if [ -f /etc/systemd/system/mycroft.service ]
then
	sudo rm /etc/systemd/system/mycroft.service
fi

echo "[Unit]" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "Description=Mycroft personal AI" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "After=pulseaudio.service" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "After=network.target" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "[Service]" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "User=pi" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "WorkingDirectory=/home/pi/mycroft-core" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "ExecStart=/home/pi/mycroft-core/start-mycroft.sh all" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "ExecStop=/home/pi/mycroft-core/stop-mycroft.sh" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "Type=forking" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "Restart=always" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "RestartSec=3" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "[Install]" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null
echo "WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/mycroft.service > /dev/null

sudo chmod +x /etc/systemd/system/mycroft.service
sudo systemctl enable mycroft.service

echo
echo 'Creation of mycroft service complete'
echo

##########################################################################

sleep 2

echo "Do you want to install the Finished Booting skill?"
echo -n "Choice [y/n]: "
while true; do
  read -N1 -s key
  case $key in
    y)
      echo
      echo 'Install Finished Booting skill'
      echo

      /home/pi/mycroft-core/bin/mycroft-msm install skill-finished-booting

      echo
      echo 'Finished Booting skill installed'
      echo
      break
      ;;
    n)
      echo
      echo 'Skipping skill install'
      echo
      break
      ;;
  esac
done

##########################################################################

sleep 2

echo "Do you want to install Respeaker Mic Array v2.0 Pixel Ring skill?"
echo -n "Choice [y/n]: "
while true; do
  read -N1 -s key
  case $key in
    y)
      echo
      echo 'Install Respeaker Mic Array v2.0 Pixel Ring skill'
      echo

      if [ -f /etc/udev/rules.d/55-seeedusb-perms.rules ]
      then
      	sudo rm /etc/udev/rules.d/55-seeedusb-perms.rules
      fi

      echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="2886", ATTR{idProduct}=="0018", GROUP="plugdev", MODE="0666"' | sudo tee -a  /etc/udev/rules.d/55-seeedusb-perms.rules > /dev/null

      /home/pi/mycroft-core/bin/mycroft-msm install https://github.com/arraylabs/mycroft-respeaker-usb-pixel-ring.git

      echo
      echo 'Respeaker Mic Array v2.0 Pixel Ring skill installed'
      echo
      break
      ;;
    n)
      echo
      echo 'Skipping skill install'
      echo
      break
      ;;
  esac
done

##########################################################################

sleep 2

echo
echo 'Reboot is required for changes to take effect'
echo

echo "Do you want to reboot now?"
echo -n "Choice [y/n]: "
while true; do
  read -N1 -s key
  case $key in
    y)
      echo
      echo 'Rebooting in 3 seconds'
      echo
      sleep 3
      sudo reboot
      break
      ;;
    n)
      echo
      echo "Reboot skipped but still required for services to start and changes to take effect"
      echo
      break
      ;;
  esac
done
