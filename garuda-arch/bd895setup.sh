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
sudo wget -O ~/.local/bin/odin-player https://github.com/badvibecoder/odin-player/releases/download/v0.1.1/odin-player
sudo wget -O ~/.local/bin/odin-trainer https://github.com/badvibecoder/odin-trainer/releases/download/v0.1.0/odin-trainer
sudo wget -O ~/.local/bin/vibetyper https://github.com/badvibecoder/vibetyper/releases/download/v0.1.0/vibetyper
sudo wget -O ~/.local/bin/vibekeytester https://github.com/badvibecoder/vibekeytester/releases/download/v0.1.0/vibekeytester
sudo chmod +x ~/.local/bin/{odin-player,odin-trainer,vibetyper,vibekeytester}

# Install Ollama and configure for Navi21
curl -fsSL https://ollama.com/install.sh | sh
sudo mkdir -p /etc/systemd/system/ollama.service.d
printf '[Service]\nEnvironment="HSA_OVERRIDE_GFX_VERSION=10.3.0"\nEnvironment="OLLAMA_FLASH_ATTENTION=1"\nEnvironment="OLLAMA_KV_CACHE_TYPE=q8_0"\n' | sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null
sudo systemctl daemon-reload
sudo systemctl restart ollama.service

# Generate ollama-pull.sh inside ~/Documents
cat << 'EOF' > "$HOME/Documents/ollama-pull.sh"
#!/usr/bin/env bash

ollama pull ornith-1.5:9b
ollama pull qwen3.8:27b
ollama pull gemma4:latest
ollama pull gpt-oss:20b

EOF

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

cat << 'EOF' > "$HOME/Documents/dsh-project-template.md"
# Project Spec — <name>

## 1. Goal & Vibe
*   **Purpose:** (1-2 lines defining what the app does)
*   **Aesthetic/Sensory:** (e.g., Synthwave/Darkwave visual style, specific audio cues like mechanical thocks)
*   **Non-goals:** (Explicit bullet points of what we are strictly NOT building)

## 2. Donor Code & Context Maps
*   **Skeleton/Donor:** [Insert path, e.g., `./vibetyper`]. Use this as the base skeleton. Keep [X, Y, Z features], but strip out [A, B, C features].
*   **Reference Data:** [Insert paths, e.g., `./odinbook`, `./odinreference`]. Treat these directories as the absolute source of truth for all syntax, logic, and training examples.

## 3. Core Requirements & Logic
1.  (Requirement 1) -> [Acceptance criteria]
2.  (Requirement 2) -> [Acceptance criteria]
3.  (Requirement 3) -> [Acceptance criteria]

## 4. Execution Phases (Gated)
*Wait for human approval before advancing to the next phase.*
*   **Phase 1: Architecture & Co-Design:** Review the Reference Data and Donor Code. Propose a structural plan and ask questions. **Do not write code yet.**
*   **Phase 2: Data Extraction & Setup:** Parse the reference directories, set up the project skeleton from the Donor Code, and confirm it runs.
*   **Phase 3: Beta Build:** Implement the Core Requirements.
*   **Phase 4: Polish:** Apply the Aesthetic/Sensory rules and refine.

=== STANDING RULES (Do not edit) ===
- **Read-Only Context:** Never modify or delete the Donor Code or Reference Data directories.
- **Zero Hallucination:** Never invent language syntax or commands; pull exclusively from the provided Reference Data.
- **Incremental Commits:** Deliver in the exact phases above. Build, test, and commit each phase.
- **Graceful Failures:** Invalid input must result in clean error handling, never a hard crash.
EOF

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


cat << 'EOF' > "$HOME/Documents/background-bananaprompt-anime.txt"
A dramatic, wide-angle cinematic anime illustration in a polished, detailed cel-shaded art style. The foreground features a close-up three-quarter view of a young anime girl with a short dark bob haircut, wearing an oversized mustard-yellow t-shirt and a dark grey backpack strap over her shoulder. She is looking up and to the right with a deeply sorrowful expression and visible tears streaming down her cheek. Her face is starkly lit by a warm, orange-yellow light from the right, contrasting heavily with deep, cool indigo shadows on the left. The background is a melancholic edge-of-town landscape at twilight. The sky is deep indigo and dark blue with subtle stylized clouds. On the right horizon, a large orange-yellow setting sun casts a vibrant low glow. Utility poles and wires stretch down the right side of an empty asphalt road toward the horizon, where a tiny, solitary silhouetted human figure stands in the distance. On the left, a cluster of silhouetted factory buildings is visible. The overall style features clean, sharp line work, flat colors with crisp cel-shaded shadows, and a cinematic 90s retro-anime aesthetic with a highly detailed finish.
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

# Lact setup post install, grub, reboot
# sudo tee /etc/lact/config.yaml > /dev/null << 'EOF'
# version: 7
# daemon:
#   log_level: info
#   admin_group: wheel
#   disable_clocks_cleanup: false
# apply_settings_timer: 5
# gpus:
#   1002:73A5-1EAE:6950-0000:03:00.0:
#     fan_control_enabled: true
#     fan_control_settings:
#       mode: curve
#       static_speed: 0.5
#       temperature_key: edge
#       interval_ms: 500
#       curve:
#         40: 0.25
#         48: 0.34
#         56: 0.45
#         63: 0.54
#         71: 0.64
#       spindown_delay_ms: 8000
#       change_threshold: 2
#     performance_level: auto
#     max_core_clock: 2400
#     voltage_offset: -40
# current_profile: null
# auto_switch_profiles: false
# EOF

