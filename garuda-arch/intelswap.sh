#!/usr/bin/env bash

sudo systemctl disable --now lactd
sudo pacman -R lact

sudo sed -i 's/amdgpu\.dcdebugmask=0x10 //g; s/amdgpu\.ppfeaturemask=0xffffffff//g; s/  */ /g' /etc/default/grub
sudo update-grub

sudo pacman -S --needed vulkan-intel lib32-vulkan-intel intel-compute-runtime level-zero-loader intel-media-driver libva-utils intel-gpu-tools

pacman -Q vulkan-intel intel-compute-runtime
sudo usermod -aG render $USER

#sudo pacman -R vulkan-radeon lib32-vulkan-radeon
#post reboot
vainfo --display drm --device /dev/dri/renderD128
vulkaninfo | grep -i "ray_tracing"

