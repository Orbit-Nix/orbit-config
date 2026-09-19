# ❄️ OrbitOS

Declarative, multi-host, multi-dots, feature-full, flake based NixOS configs.

---

## 🖥️ Hosts

| Host            | Codename | Role | Hardware | Default Shell |
|:----------------| :--- | :--- | :--- | :--- |
| `lt-hp15-nix`   | **Orion** | Coding & Remote desktop | HP 15 Laptop, Intel Core i5 8th gen, NVIDIA GeForce MX150, 24GB DDR4, 1.5TB Total Storage | `end4-pC` |
| `pc-smile-nix`  | **Andromeda** | Gaming & Workstation | Ryzen 5 5600, RTX 5050, 16 GB DDR4, 512 GB Total Storage | `end4-pC` |
| `srv-c4030-nix` | **Lunar** | Server & WoL Relay | Lenovo AIO C40-30, Intel Core i3-4005U, NVIDIA GeForce 820A, 4GB DDR3L, 4.5TB Total Storage | *Headless* |
| `prt-roam-nix`  | **Voyager** | Portable / General | Universal Hardware, Disko tmpfs root | `end4-pC` |

---

## 📁 Repository Structure

```
/orbitos/
├── config/                 # Modular user dotfiles & app configurations
│   ├── cursor/             # Dynamic wallpaper-matching cursor generator
│   ├── fish/               # Fish shell configuration & environment
│   ├── gtk-3.0/            # GTK 3 custom stylesheets
│   ├── gtk-4.0/            # GTK 4 custom stylesheets
│   ├── hypr/               # Hyprland lua configurations & rules
│   └── kitty/              # Kitty terminal configuration
├── flake.nix               # Flake inputs, outputs, and system definitions
├── hosts/                  # Per-host NixOS machine definitions
│   ├── lt-hp15-nix/        # Orion (Laptop)
│   ├── pc-smile-nix/       # Andromeda (Main PC)
│   ├── srv-c4030-nix/      # Lunar (Server & WoL Relay)
│   └── prt-roam-nix/       # Voyager (Portable)
├── modules/                # Modular system & hardware configurations
│   ├── desktop/
│   │   ├── app-configs/    # Per-app integration hooks (fish, gtk, hypr, kitty)
│   │   ├── app-configs.nix # Modular app layer & overwrite engine
│   │   ├── apps.nix        # System-wide GUI apps and tools
│   │   ├── assets/         # Wallpapers and media
│   │   ├── gaming.nix      # Steam, GameMode, Minecraft, controller drivers
│   │   ├── remote-desktop/ # Sunshine streaming host & Moonlight client
│   │   ├── shells.nix      # NixOS-level desktop shell module (mySystem.desktop.shell)
│   │   └── shells/         # Modular Desktop Shells (end4-pC, midnight, dms)
│   ├── core/               # Base system, OpenSSH, nh, and networking
│   ├── hardware/           # Modular CPU & GPU hardware profiles
│   ├── roles/              # Server and workstation role profiles
│   └── services/           # Docker stacks, filesystem, restic, and users
├── secrets/
│   └── ssh.tar.age         # Passphrase-encrypted ~/.ssh archive bundle
└── users/                  # Modular user accounts & user environments
    ├── m_uvex/             # Musa Murad (NixOS account & Home Manager environment)
    ├── incognito/          # Ephemeral tmpfs user
    └── oliver/             # Oliver (Pocketbase dev user)
```

---

## 🐚 Modular Desktop Shells (3-Shell Suite)

OrbitOS features 3 switchable, beginner-friendly desktop shells:

1. **`end4-pC`** (Illogical Impulse) — Feature-rich Material 3 Quickshell desktop with dynamic sidebar, widgets, overview, and system control center.
2. **`midnight`** (Midnight Shell) — Sleek, refined Caelestia fork ([`dim-ghub/midnight-shell`](https://github.com/dim-ghub/midnight-shell)) with a minimalist QML interface.
3. **`dms`** (DankMaterialShell) — High-performance Material shell ([`AvengeMedia/DankMaterialShell`](https://github.com/AvengeMedia/DankMaterialShell)) with plugin registry, `dgop` monitoring stats, `cava` audio visualizer, and `matugen` dynamic theming.

### 1. Instant Runtime Switching via `orbit shell`

Switch shells instantly on-the-fly without rebuilding:

```bash
# Interactive selector menu:
orbit shell

# Or switch directly by shell name:
orbit shell end4-pC
orbit shell midnight
orbit shell dms
orbit shell none

# List all available shells:
orbit shell list

# Check currently active shell:
orbit shell status

# Restart the active shell:
orbit shell restart
```

### 2. Per-Host Declarative Shell Selection

Each host sets its default shell in its machine definition `hosts/{hostname}/default.nix`:

```nix
# In hosts/lt-hp15-nix/default.nix (or pc-smile-nix / prt-roam-nix):
mySystem.desktop.shell = "midnight"; # Choices: "end4-pC" | "midnight" | "dms" | "none"
```

Rebuild to apply:
```bash
rebuild
# or
orbit
```

---

## ✨ Key Features

* **Modular 3-Shell Desktop Suite:** Seamlessly switch between **end4-pC**, **Midnight Shell**, and **DankMaterialShell** via `orbit shell {shellname}` or per-host in `hosts/{hostname}/default.nix`.
* **Modular User Management:** User accounts and their respective desktop/service environments live under `users/`, allowing any host to reference only the users it needs.
* **Dynamic Material Cursors:** Cursors dynamically adapt to wallpaper palettes across Hyprland, GTK3/4, Qt, and X11 in all 3 desktop shells.
* **Masterized SSH across devices:** `~/.ssh` is encrypted with age passphrase and committed. On first rebuild, it extracts all keys using the passphrase.
* **Orbit CLI Tool:** Fast, unified Rust CLI tool (`orbit`) for system rebuilds with visual diffs, package search/running (`orbit run <pkg>`), secrets management (`orbit secrets`), and instant shell switching (`orbit shell <shell>`).
* **Remote Kiosk Specialisation:** Selectable boot-entry on Orion (`remote-kiosk`) boots directly into Moonlight sending a background Wake-on-LAN magic packet via Lunar to Andromeda.
* **Tailscale WoL Relay:** Built-in alias (`wake-pc`) and scripts allowing remote devices to trigger Wake-on-LAN on Andromeda via the always-on Lunar server node.

---

## 🚀 Quick Install (Fresh System)

(!) It is advised to fork this repo into your own and edit the config as you like, especially the user as the password is hashed and with this exact config you won't be able to get in!

### 1. Install NixOS

- Visit `https://nixos.org/download/`
- Select and download your preferred ISO file.
- Flash the ISO file onto a USB drive and boot into the installer.

### 2. Generate Hardware Config & Clone Repo

- Once booted into the live environment, launch a terminal:
```bash
# Get into a temporary shell with git installed
nix-shell -p git

# Clone repo to /orbitos and create symlink for compatibility
sudo git clone https://github.com/m-uvex/NixOS.git /orbitos
sudo ln -s /orbitos /etc/nixos

# Generate hardware profile into host (e.g. lt-hp15-nix)
sudo nixos-generate-config --root /orbitos/hosts/lt-hp15-nix/
```

### 3. Build & Install
```bash
cd /orbitos
sudo git add .
sudo nixos-install --flake .#lt-hp15-nix
# Enter age decryption passphrase when prompted to restore ~/.ssh

sudo reboot
```

After first install, manage your system with `rebuild` or `orbit`.
