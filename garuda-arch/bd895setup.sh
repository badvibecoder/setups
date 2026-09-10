#!/usr/bin/env bash

# bd895i system
# 64GB RAM 8945hx 16c 
# rx 6950 xt
# 2 x 4TB nvme

# Base apps
sudo pacman -Syu git openssh lact yay rclone vim curl wget steam obs-studio yt-dlp luanti s-tui micro nodejs npm bun odin

yay -S --noconfirm google-chrome visual-studio-code-bin 

curl -LsSf https://astral.sh/uv/install.sh | sh

# Grab my programs
sudo wget -O ~/.local/bin/odin-player https://github.com/badvibecoder/odin-player/releases/download/v0.1.0/odin-player
sudo wget -O ~/.local/bin/odin-trainer https://github.com/badvibecoder/odin-trainer/releases/download/v0.1.0/odin-trainer
sudo wget -O ~/.local/bin/vibetyper https://github.com/badvibecoder/vibetyper/releases/download/v0.1.0/vibetyper
sudo wget -O ~/.local/bin/vibekeytester https://github.com/badvibecoder/vibekeytester/releases/download/v0.1.0/vibekeytester
sudo chmod +x ~/.local/bin/{odin-player,odin-trainer,vibetyper,vibekeytester}

# curl -fsSL https://ollama.com/install.sh | sh

# yt-dlp gathering
# Generate yt.sh inside ~/Documents
cat << 'EOF' > "$HOME/Documents/yt.sh"
#!/usr/bin/env bash

YT=(
  "https://www.youtube.com/watch?v=3JqQaxiHF-w"
  "https://www.youtube.com/watch?v=UfqOEyLFrJI"
  "https://www.youtube.com/watch?v=sR__tFHNcBg"
  "https://www.youtube.com/watch?v=am1VJP0RnmQ"
  "https://www.youtube.com/watch?v=fhL67fnDXcU"
  "https://www.youtube.com/watch?v=y2ECgOhoDGs"
)

yt-dlp -x --audio-format mp3 --audio-quality 128k --no-overwrites \
  --min-sleep-interval 15 \
  --max-sleep-interval 40 \
  --limit-rate 3M \
  -o "$HOME/Music/%(channel)s/%(title)s.%(ext)s" \
  "${YT[@]}"
EOF

chmod +x "$HOME/Documents/yt.sh"

# Update grub for RDNA2
sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/'\$/ amdgpu.dcdebugmask=0x10 amdgpu.ppfeaturemask=0xffffffff'/" /etc/default/grub

sudo update-grub

# Onedrive setup
mkdir ~/OneDrive

sudo tee /etc/systemd/system/onedrive.service > /dev/null << 'EOF'
[Unit]
Description=OneDrive over rclone Daemon
After=network-online.target
Wants=network-online.target

[Service]
User=pcarroll
Type=simple
ExecStart=/usr/bin/rclone --vfs-cache-mode writes mount OneDrive: /home/pcarroll/OneDrive/ --config /home/pcarroll/.config/rclone/rclone.conf
ExecReload=/bin/kill -s HUP $MAINPID
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# rclone - sign in on browser first
#rclone config

# after rclone config is ran
# sudo systemctl daemon-reload && sudo systemctl enable onedrive.service && sudo systemctl start onedrive.service && sudo systemctl status onedrive.service

# reboot
# sudo reboot
# Validate mem clocks in game with this
# cat /sys/class/drm/card*/device/pp_dpm_mclk
# Validate rebar/sam with this
# cat /sys/class/drm/card*/device/mem_info_vis_vram_total

# run deepseek harness
# nohup bunx @deepseek-ai/dsh web > /dev/null 2>&1 &
# jobs , then kill %1 to end
mkdir -p ~/dev/dsh

# Lact setup post install, grub, reboot
sudo tee ~/.config/lact/ui.yaml > /dev/null << 'EOF'
version: 7
daemon:
  log_level: info
  admin_group: wheel
  disable_clocks_cleanup: false
apply_settings_timer: 5
gpus:
  1002:73A5-1EAE:6950-0000:03:00.0:
    fan_control_enabled: true
    fan_control_settings:
      mode: curve
      static_speed: 0.5
      temperature_key: edge
      interval_ms: 500
      curve:
        40: 0.25
        48: 0.34
        56: 0.45
        63: 0.54
        71: 0.64
      spindown_delay_ms: 8000
      change_threshold: 2
    performance_level: auto
    max_core_clock: 2400
    voltage_offset: -40
current_profile: null
auto_switch_profiles: false
EOF

