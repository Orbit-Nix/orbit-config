# ❄️ OrbitOS

Declarative, multi-host, multi-shells, feature-full, flake based NixOS configs.

---

## 🖥️ Hosts

| Host            | Codename      | Role                    | Hardware                                                                                    | Default Shell |
|:----------------|:--------------|:------------------------|:--------------------------------------------------------------------------------------------|:--------------|
| `lt-hp15-nix`   | **Orion**     | Coding & Remote desktop | HP 15 Laptop, Intel Core i5 8th gen, NVIDIA GeForce MX150, 24GB DDR4, 1.5TB Total Storage   | `end4-pC`     |
| `pc-smile-nix`  | **Andromeda** | Gaming & Workstation    | Ryzen 5 5600, RTX 5050, 16 GB DDR4, 512 GB Total Storage                                    | `end4-pC`     |
| `srv-c4030-nix` | **Lunar**     | Server & WoL Relay      | Lenovo AIO C40-30, Intel Core i3-4005U, NVIDIA GeForce 820A, 4GB DDR3L, 4.5TB Total Storage | *Headless*    |
| `prt-roam-nix`  | **Voyager**   | Portable / General      | Universal Hardware, Disko tmpfs root                                                        | `end4-pC`     |

---

## 📁 Repository Structure

```
/orbitos/
├── config/                 # User apps/tools dotfiles
│   ├── cursor/             # Wallpaper-matching Material design mouse cursor
│   ├── fish/               # Fish shell configuration
│   ├── gtk-3.0/            # GTK 3 custom stylesheets
│   ├── gtk-4.0/            # GTK 4 custom stylesheets
│   ├── hypr/               # Hyprland blur configuration
│   ├── kitty/              # Kitty terminal configuration
│   ├── nixpkgs/            # Nixpkgs configuration
│   └── starship/           # Starship prompt configuration
├── flake.nix               # Flake inputs, outputs, and system definitions
├── hosts/                  # Per-host NixOS machine definitions
│   ├── lt-hp15-nix/        # Orion (Laptop)
│   ├── pc-smile-nix/       # Andromeda (Main PC)
│   ├── srv-c4030-nix/      # Lunar (Server & WoL Relay)
│   └── prt-roam-nix/       # Voyager (Portable)
├── modules/                # Modular system & hardware configurations
│   ├── core/               # Base system, OpenSSH, nh, and networking
│   ├── desktop/
│   │   ├── app-configs/    # Per-app dotfiles (fish, gtk, hypr, kitty, etc)
│   │   ├── app-configs.nix # Modular app layer & overwrite engine (for dotfiles above)
│   │   ├── apps.nix        # System-wide GUI apps and tools
│   │   ├── assets/         # Wallpapers and media
│   │   ├── gaming.nix      # System-wide gaming apps & launchers + controller support
│   │   ├── ollama.nix      # Ollama local LLM server and GUI for local AI
│   │   ├── remote-desktop/ # Sunshine streaming host & Moonlight client
│   │   ├── shells.nix      # NixOS-level desktop shell module (mySystem.desktop.shell)
│   │   └── shells/         # Modular Desktop Shells (end4-pC, midnight, dms)
│   ├── hardware/           # Modular CPU and GPU hardware profiles + Swap & ZRAM config
│   ├── roles/              # Server and workstation role profiles
│   └── services/           # Docker stacks, filesystem, restic, and users
│       └── stacks/         # Modular Docker Compose stacks
├── pkgs/                   # Custom packages
├── secrets/
│   └── ssh.tar.age         # Passphrase-encrypted ~/.ssh archive bundle
└── users/                  # Modular user accounts & user environments
    ├── incognito/          # Ephemeral user that only gets loaded in RAM, leaving no trace behind.
    ├── m_uvex/             # Personal m_uvex user (NixOS account & Home Manager environment)
    └── oliver/             # Remote Oliver user for server (Pocketbase dev user)
```

---

## ✨ Key Features

### Core & System
* **Everything Is Modular!:** Everything is modularized in different files so removing or adding a feature, user, or app is as easy as editing your host's `default.nix`.
* **Modular Hardware Profiles:** No more hours of fiddling around trying to get NVIDIA drivers running. Simply drop-in modular CPU and GPU hardware profiles from `modules/hardware/`.
* **Orbit CLI Tool:** [Orbit-CLI](https://github.com/Orbit-Nix/orbit-cli) pre-installed and ready to go out the box.
* **Unified Secrets Management:** Encryptable secrets (such as SSH keys and soon to come WiFi passwords) to be synced across all hosts using a passphrase.
* **Modern CLI Utilities:** Ships with fast, Rust-based alternatives for classic tools, automatically aliased for a seamless transition.

### Desktop & Experience
* **Hyprland Shells Switcher:** Seamlessly & quickly switch between different popular Hyprland shells/dotfiles via `orbit shell`.
* **Dynamic Material Cursors:** Cursors dynamically adapt to wallpaper palettes across Hyprland, GTK3/4, Qt, and X11 in all 3 desktop shells.
* **Native Android Integration:** KDE Connect, RQuickShare, LocalSend, and more tools are available natively to integrate your PC and smartphone seamlessly.
* **Local AI Made Easy:** Native integration for local LLMs via Ollama with easy-to-use GUI options.
* **Gaming Ready:** Configurable system-wide gaming apps, Minecraft launchers and built-in controller support pre-configured.

### Networking & Remote
* **Remote Desktop Host:** Use your most powerful machine from anywhere via moonlight|sunshine & Tailscale by setting it as a remote desktop host.
* **Remote Desktop Client:** Add a boot entry to your laptop or any portable machine to directly access the remote desktop host with no extra bloat or hassle.
* **Tailscale WoL Relay:** Built-in alias (`wake-pc`) allowing remote devices to trigger Wake-on-LAN on any device in your home using a homeserver.
* **Homeserver Support:** Integrated Docker containers of some of the most helpful tools to get you started with self-hosting, including easy user management powered by Authelia.

### Flexibility & Security
* **Incognito User:** Doing sus activity? Use Incognito on a system level. User session is entirely loaded into RAM and the second you log out or reboot, everything gets erased.
* **Portable USB:** Install the portable host with universal hardware profiles on a USB drive and have your own configs anywhere, anytime, any-host!
* **Easy User Management:** User accounts and their respective desktop/service environments live under `users/`, allowing any host to reference only the users it needs.

---


## 🚀 Quick Install

> [!WARNING]
> This is my personal implementation of OrbitOS, it is the most unstable and not advised to be installed unless you know what you're doing.
>
> Please use the [OrbitOS Template](https://github.com/Orbit-Nix/OrbitOS) instead, and refer to [This guide](https://github.com/Orbit-Nix/orbit-cli/blob/main/INSTALLOS.md) to build and install.