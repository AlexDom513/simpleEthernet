#!/bin/bash

################################################
# serial_config.sh
# 8/11/24
################################################

# Function to list all USB tty ports
list_usb_tty_ports() {
  echo "Listing all USB tty ports:"
  ls /dev/ttyUSB* 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "No USB tty ports found."
  fi
}

# Function to help with Minicom configuration
configure_minicom() {
  echo "Configuring Minicom..."
  echo "Available USB tty ports:"
  tty_ports=$(ls /dev/ttyUSB* 2>/dev/null)
  if [ $? -ne 0 ]; then
    echo "No USB tty ports found. Exiting."
    exit 1
  fi
  select tty_port in $tty_ports; do
    if [ -n "$tty_port" ]; then
      sudo minicom -s -c on
      sudo minicom -D "$tty_port"
      break
    else
      echo "Invalid selection. Please try again."
    fi
  done
}

# Main script execution
list_usb_tty_ports

echo "Do you want to configure Minicom now? (y/n)"
read answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
  configure_minicom
else
  echo "Exiting without configuring Minicom."
fi
