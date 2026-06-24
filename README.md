# kjp — NixOS host + self-installing ISO

NixOS config for the **kjp** server (VMware guest, XFCE, Samba, Docker).
The flake defines two things:

- **`kjp`** — the real system, with declarative disk layout (disko) and passwords.
- **`installer`** — a bootable live ISO that carries this flake and installs `kjp` in one command.

Disk layout (`disko.nix`): single GPT disk → 512 MB ESP (`/boot`) + rest ext4 (`/`).

---

## Install (easiest: stock ISO + `disko-install`)

No custom ISO needed. `disko-install` partitions, formats, mounts **and** installs in a single command.

1. Boot the official **NixOS minimal ISO** in the VM
   (https://channels.nixos.org/nixos-26.05/latest-nixos-minimal-x86_64-linux.iso).
   Networking comes up via DHCP automatically.
2. `sudo -i`, then run (⚠️ **wipes the target disk** — check the device with `lsblk`):

   ```bash
   nix --extra-experimental-features 'nix-command flakes' \
     run 'github:nix-community/disko/latest#disko-install' -- \
     --flake 'github:mortegro/kjp-server-lukasstiftung#kjp' \
     --disk main /dev/sda
   ```

   `--disk main /dev/sda` maps the disko disk named `main` to the real device — change
   `/dev/sda` to `/dev/nvme0n1` etc. if needed; no file edit required.
3. `reboot`, detach the ISO. Done. Root and `matthias` passwords are baked in.

## Install (custom self-installing ISO)

Build the ISO that already contains this flake:

```bash
nix --experimental-features 'nix-command flakes' \
  build '.#nixosConfigurations.installer.config.system.build.isoImage'
cp -L result/iso/*.iso ~/kjp-installer.iso
```

Boot it (root SSH key + password pre-set, DHCP up), then just:

```bash
install-kjp        # runs disko + nixos-install --flake /etc/nixos#kjp
```

## Manual partitioning (fallback)

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko/latest -- --mode destroy,format,mount ./disko.nix
sudo nixos-install --flake .#kjp
```

---

## After install

Future changes are just:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#kjp
```

## Notes

- Target release: **nixos-26.05** (pinned in `flake.lock`).
- VMware guest tooling (`open-vm-tools`) and `vmware` X11 driver are enabled.
- `herdr` is commented out in `configuration.nix` (not in nixpkgs — needs an overlay).
