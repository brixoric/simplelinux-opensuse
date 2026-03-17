#!/bin/bash

# TODO: Add tar extraction code and windows cleanup

#!/bin/bash

# Below is GPT expansion to grow root. Written by Gemini and not me because its too late at night and i hate bash because its just weird.
# --- CONFIGURATION ---
DISK="/dev/sda"
PART_NUM="3"
MOUNT_POINT="/"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "Error: Please run as root (sudo)."
   exit 1
fi

echo "--- Initializing GPT Online Expansion ---"

# 1. Install growpart (required for GPT online resizing)
if ! command -v growpart &> /dev/null; then
    echo "Installing 'growpart' (cloud-utils)..."
    sudo zypper install -y growpart || { echo "Failed to install growpart."; exit 1; }
fi

# 2. Expand the GPT partition
# growpart automatically handles moving the GPT backup header to the new end of the disk
echo "Expanding partition ${DISK}${PART_NUM}..."
sudo growpart "$DISK" "$PART_NUM"
if [[ $? -ne 0 ]]; then
    echo "Expansion failed. Ensure free space is immediately after partition ${PART_NUM}."
    exit 1
fi

# 3. Reload the partition table into the kernel
echo "notifying kernel of partition changes..."
sudo partprobe "$DISK"

# 4. Grow the Btrfs filesystem to fill the new partition space
echo "resizing btrfs on ${MOUNT_POINT}..."
sudo btrfs filesystem resize max "$MOUNT_POINT"

echo "finished"
df -h "$MOUNT_POINT"

# TODO:
# Add first boot stuff here

# time to extract stuff and demolish microslop's garbage excuse for an OS.
tar -xf /prep/targz/docs.tar.gz -C $HOME/Documents/
tar -xf /prep/targz/recentDownloads.tar.gz -C $HOME/Downloads/
tar -xf /prep/targz/pictures.tar.gz -C $HOME/Pictures/
tar -xf /prep/targz/desktop.tar.gz -C $HOME/Desktop/
tar -xf /prep/targz/onedrive.tar.gz -C $HOME/OneDrive/
cp -r /prep/chrome_data/ $HOME/chrome_data/
echo "Raw chrome data. Just for looking at" >> $HOME/chrome_data/what.txt
mount /dev/sda1 /efi/
