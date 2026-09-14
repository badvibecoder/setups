#!/usr/bin/env bash

sudo dnf update -y

# Install apps
sudo dnf install git curl wget rclone nodejs vim minetest openssh-server s-tui age obs-studio steam -y
sudo systemctl enable --now sshd

# Install bun
curl -fsSL https://bun.sh/install | bash
echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc

# Run deepseek harness
#
# "dsh" to run, "dsh-kill" to stop
#
# Manual check: 'pgrep -fl "@deepseek-ai/dsh"'
#
# nohup bunx @deepseek-ai/dsh web > /dev/null 2>&1 &
# jobs , then kill %1 to end
mkdir -p ~/dev/dsh
mkdir -p ~/.local/bin
cat << 'EOF' > ~/.local/bin/dsh
#!/usr/bin/env bash
nohup bunx @deepseek-ai/dsh web > /dev/null 2>&1 &
EOF
chmod +x ~/.local/bin/dsh
# Add dsh-kill
cat << 'EOF' > ~/.local/bin/dsh-kill
#!/usr/bin/env bash
if pkill -f "@deepseek-ai/dsh"; then
  echo "Terminated dsh."
else
  echo "No running dsh process found."
fi
EOF
chmod +x ~/.local/bin/dsh-kill

# Install Odin
sudo dnf install git clang llvm-devel -y
# Clone to standard local directory
git clone https://github.com/odin-lang/Odin.git ~/.local/share/odin
cd ~/.local/share/odin
./build_odin.sh release
echo 'export ODIN_ROOT="/home/$USER/.local/share/odin"' >> ~/.bashrc
echo 'export PATH="$PATH:~/.local/share/odin"' >> ~/.bashrc
####
# In coderunner
#
# In "Echo-runner.executorMap":{
# add 
# "odin": "cd $dir && odin build $fileName -file -out:$fileNameWithoutExt && ./$fileNameWithoutExt; rm -f $fileNameWithoutExt",
#
# In "code-runner.executorMapByFileExtension": {
# add
# ".odin": "cd $dir && odin build $fileName -file -out:$fileNameWithoutExt && ./$fileNameWithoutExt; rm -f $fileNameWithoutExt",
#
####

# Install vscode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
dnf check-update
sudo dnf install code -y

# Install chrome
sudo dnf config-manager enable google-chrome
sudo dnf install google-chrome-stable -y

# Rclone setup
mkdir ~/OneDrive
#rclone config
# Create rclone service file
sudo tee /etc/systemd/system/onedrive.service <<'EOF'
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
# Enable and start service
#sudo systemctl daemon-reload && sudo systemctl enable onedrive.service && sudo systemctl start onedrive.service && sudo systemctl status onedrive.service

# Install uv and atuin
curl -LsSf https://astral.sh/uv/install.sh | sh
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
# Sometimes atuin will not setup ~/.bashrc correctly, make sure you have this:
####
. "$HOME/.atuin/bin/env"
eval "$(atuin init bash)"
####

# Arc GPU specific setup
sudo dnf install libva-intel-media-driver mesa-dri-drivers mesa-vulkan-drivers mesa-va-drivers intel-compute-runtime intel-level-zero intel-level-zero-devel intel-ocloc intel-opencl clinfo libvpl libva-utils intel-level-zero-gpu-raytracing -y
# Enable nonfree repo
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
# Oneapi required items
sudo dnf group install development-tools -y
sudo dnf install cmake pkgconfig -y
sudo dnf install gcc-c++ -y
# Add user to video,render groups, this will be required for other uses
sudo usermod -aG video,render $USER
# Validate GPU is showing
clinfo | grep "Device Name"
lspci -nnk | grep -A3 VGA
# Validate primary GPU is listed as GPU0
vulkaninfo --summary
# Update Fedora and reboot
# # # # # # # # # # # # # #
# At this point we can install oneapi basetoolkit with either the yum package or the sh offline script
# yum will install /opt/intel/oneapi vs ~/intel/oneapi for the offline script.
# sudo yum install intel-oneapi-toolkit -y
# # # # # # # # # # # # # #

# Install Ollama and configure for Vulkan (ARC GPU)
curl -fsSL https://ollama.com/install.sh | sh
# Create the override directory for the ollama service
sudo mkdir -p /etc/systemd/system/ollama.service.d
# Write the environment variables directly to the override file
sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null << 'EOF'
[Service]
Environment="OLLAMA_VULKAN=1"
Environment="GGML_VK_VISIBLE_DEVICES=0"
Environment="OLLAMA_FLASH_ATTENTION=1"
Environment="OLLAMA_KV_CACHE_TYPE=q8_0"
EOF
sudo systemctl daemon-reload
sudo systemctl restart ollama.service

# Disable kwallet
mkdir -p ~/.config
cat << 'EOF' > ~/.config/kwalletrc
[Wallet]
Enabled=false
EOF

